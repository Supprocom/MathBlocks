using System.Runtime.InteropServices;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>The slot arena of one call on one input set, on the device, with the launches and the readback of its outputs.</summary>
internal sealed class VectorBlockRun : IDisposable
{
    private const int Alignment = 16;
    private const int StepBytes = 5 * sizeof(int);
    private const int LaunchesPerCell = 7;

    private readonly Action<IntPtr> launch;
    private readonly Action begin;
    private readonly Func<float> end;
    private readonly VectorBlockCall call;
    private readonly MathBlockCudaOperationPlan[] plans;
    private readonly int[] outputSlotOffsets;
    private readonly int[] outputPayloadOffsets;
    private readonly int arenaBytes;
    private readonly IntPtr hostArena;
    private readonly ulong deviceArena;
    private readonly IntPtr argumentBlock;
    private readonly IntPtr[] argumentBoxes;

    /// <summary>Gets the scratch bytes each dispatch was planned with.</summary>
    internal int[] ScratchBytes { get; }

#pragma warning disable MA0051
    internal VectorBlockRun(VectorBlockDevice device, VectorBlockCall call, MathBlockValue[][] inputs)
    {
        launch = device.Launch;
        begin = device.Begin;
        end = device.End;
        this.call = call;
        var steps = call.Contracts.Length;
        plans = new MathBlockCudaOperationPlan[steps];
        var contracts = new MathBlockCudaOperationContract[steps];
        ScratchBytes = new int[steps];
        var slotCount = 0;
        for (var step = 0; step < steps; step++)
        {
            contracts[step] = MathBlockCudaDeviceModule.GetOperation(call.Contracts[step]);
            plans[step] = contracts[step].PlanCUDA(inputs[step]);
            ScratchBytes[step] = plans[step].ScratchBytes;
            slotCount += inputs[step].Length + 1;
        }

        var slotBase = Align(steps * StepBytes);
        var cursor = slotBase + slotCount * MathBlockCudaSlotLayout.Size;
        var inputOffsets = new int[steps][];
        var scratchOffsets = new int[steps];
        outputPayloadOffsets = new int[steps];
        outputSlotOffsets = new int[steps];
        for (var step = 0; step < steps; step++)
        {
            inputOffsets[step] = new int[inputs[step].Length];
            for (var index = 0; index < inputs[step].Length; index++)
            {
                var value = inputs[step][index];
                inputOffsets[step][index] = Allocate(ref cursor, MathBlockCudaValueCodec.GetPayloadByteCount(value.Type.Kind, MathBlockCudaValueCodec.GetElementCount(value)));
            }

            outputPayloadOffsets[step] = Allocate(ref cursor, MathBlockCudaValueCodec.GetPayloadByteCount(plans[step].OutputType.Kind, plans[step].OutputCapacity));
            scratchOffsets[step] = Allocate(ref cursor, plans[step].ScratchBytes);
        }

        arenaBytes = Align(cursor);
        hostArena = Marshal.AllocHGlobal(arenaBytes);
        Clear(hostArena, arenaBytes);
        VectorBlockDriver.Require(VectorBlockDriver.cuMemAlloc(out deviceArena, new UIntPtr((ulong)arenaBytes)), "cuMemAlloc");
        var nextSlot = 0;
        for (var step = 0; step < steps; step++)
        {
            var firstInputSlot = nextSlot;
            for (var index = 0; index < inputs[step].Length; index++)
            {
                var offset = inputOffsets[step][index];
                var pointer = offset < 0 ? 0UL : deviceArena + (ulong)offset;
                MathBlockCudaValueCodec.WriteValue(hostArena, slotBase + nextSlot * MathBlockCudaSlotLayout.Size, offset, pointer, 0UL, MathBlockCudaValueCodec.GetElementCount(inputs[step][index]), inputs[step][index]);
                nextSlot++;
            }

            outputSlotOffsets[step] = slotBase + nextSlot * MathBlockCudaSlotLayout.Size;
            var layoutType = new MathBlockType(plans[step].OutputType.Kind, plans[step].OutputType.Unit, plans[step].OutputRows, plans[step].OutputColumns);
            var outputPointer = outputPayloadOffsets[step] < 0 ? 0UL : deviceArena + (ulong)outputPayloadOffsets[step];
            var scratchPointer = scratchOffsets[step] < 0 ? 0UL : deviceArena + (ulong)scratchOffsets[step];
            MathBlockCudaValueCodec.WriteHeader(hostArena, outputSlotOffsets[step], outputPointer, scratchPointer, plans[step].OutputCapacity, layoutType, valid: true);
            var descriptor = hostArena + step * StepBytes;
            Marshal.WriteInt32(descriptor, 0, (int)contracts[step].Family);
            Marshal.WriteInt32(descriptor, 4, contracts[step].Opcode);
            Marshal.WriteInt32(descriptor, 8, firstInputSlot);
            Marshal.WriteInt32(descriptor, 12, inputs[step].Length);
            Marshal.WriteInt32(descriptor, 16, nextSlot);
            nextSlot++;
        }

        VectorBlockDriver.Require(VectorBlockDriver.cuMemcpyHtoD(deviceArena, hostArena, new UIntPtr((ulong)arenaBytes)), "cuMemcpyHtoD");
        argumentBoxes = [Marshal.AllocHGlobal(sizeof(long)), Marshal.AllocHGlobal(sizeof(int)), Marshal.AllocHGlobal(sizeof(long))];
        Marshal.WriteInt64(argumentBoxes[0], unchecked((long)deviceArena));
        Marshal.WriteInt32(argumentBoxes[1], steps);
        Marshal.WriteInt64(argumentBoxes[2], unchecked((long)(deviceArena + (ulong)slotBase)));
        argumentBlock = Marshal.AllocHGlobal(argumentBoxes.Length * IntPtr.Size);
        for (var index = 0; index < argumentBoxes.Length; index++)
            Marshal.WriteIntPtr(argumentBlock, index * IntPtr.Size, argumentBoxes[index]);
    }
#pragma warning restore MA0051

    /// <summary>Launches the first <paramref name="steps"/> dispatches without waiting.</summary>
    internal void Launch(int steps)
    {
        Marshal.WriteInt32(argumentBoxes[1], steps);
        launch(argumentBlock);
    }

    /// <summary>Runs every dispatch once and returns each output as a MathBlocks value; an invalid slot is an invalid value. The kernel marks each output valid and empty before its dispatch, as InitializeOutput does.</summary>
    internal MathBlockValue[] Execute()
    {
        Launch(call.Contracts.Length);
        VectorBlockDevice.Synchronize();
        VectorBlockDriver.Require(VectorBlockDriver.cuMemcpyDtoH(hostArena, deviceArena, new UIntPtr((ulong)arenaBytes)), "cuMemcpyDtoH");
        var outputs = new MathBlockValue[plans.Length];
        for (var step = 0; step < outputs.Length; step++)
            outputs[step] = MathBlockCudaValueCodec.ReadValue(hostArena, outputSlotOffsets[step], outputPayloadOffsets[step], plans[step].OutputType);
        return outputs;
    }

    /// <summary>
    /// Times the first <see cref="VectorBlockCall.TimedSteps"/> dispatches with CUDA events: one warm-up launch, then the median of seven launches, in nanoseconds per row.
    /// </summary>
    internal float NanosecondsPerRow(int rows)
    {
        Launch(call.TimedSteps);
        VectorBlockDevice.Synchronize();
        var samples = new float[LaunchesPerCell];
        for (var index = 0; index < samples.Length; index++)
        {
            begin();
            Launch(call.TimedSteps);
            samples[index] = end();
        }

        return ProofTiming.Median(samples) / rows;
    }

    /// <summary>Frees the arena and the argument block.</summary>
    public void Dispose()
    {
        for (var index = 0; index < argumentBoxes.Length; index++)
            Marshal.FreeHGlobal(argumentBoxes[index]);
        Marshal.FreeHGlobal(argumentBlock);
        Marshal.FreeHGlobal(hostArena);
        _ = VectorBlockDriver.cuMemFree(deviceArena);
    }

    private static int Align(int value) => checked((value + Alignment - 1) & -Alignment);

    private static int Allocate(ref int cursor, int bytes)
    {
        if (bytes == 0)
            return -1;
        cursor = Align(cursor);
        var offset = cursor;
        cursor = checked(cursor + bytes);
        return offset;
    }

    // The arena is cleared in chunks, so a slot and a payload that nothing writes read as zero.
    private static void Clear(IntPtr memory, int bytes)
    {
        const int chunk = 1 << 20;
        var zeros = new byte[chunk];
        for (var offset = 0; offset < bytes; offset += chunk)
            Marshal.Copy(zeros, 0, memory + offset, Math.Min(chunk, bytes - offset));
    }

    /// <summary>Gets the description of the run for a failure message.</summary>
    public override string ToString() => $"{call.Name} {call.Parameter}";
}
