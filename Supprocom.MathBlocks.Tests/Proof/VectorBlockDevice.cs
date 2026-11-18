using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// A CUDA session for the vector-block proof: the dispatch kernel of PatternResearcher's device route compiled after the device module, with the same dispatcher block size, and the CUDA events
/// that time a launch. The file has no test-framework dependency; the 0.6.1 baseline console links it unchanged.
/// </summary>
internal sealed class VectorBlockDevice : IDisposable
{
    private const string KernelName = "proof_vector_dispatch";

    // NVRTC ignores source line endings; the kernel text is not a fingerprinted fixture. The kernel is the consumer shape of PatternResearcher's dispatch (a block dispatches one operation on the
    // slots, with the operation's family and opcode), one dispatch after another.
#pragma warning disable MA0136
    private const string KernelSource = """
        struct VectorBlockStep
        {
            int family;
            int opcode;
            int first_input_slot;
            int input_count;
            int output_slot;
        };

        extern "C" __global__ void proof_vector_dispatch(const VectorBlockStep* steps, int step_count, MathBlockSlot* slots)
        {
            for (int step = 0; step < step_count; ++step)
            {
                VectorBlockStep current = steps[step];
                if (threadIdx.x == 0)
                {
                    slots[current.output_slot].valid = 1;
                    slots[current.output_slot].count = 0;
                }

                __syncthreads();
                const MathBlockSlot* inputs[4];
                for (int index = 0; index < current.input_count; ++index)
                    inputs[index] = &slots[current.first_input_slot + index];
                mathblocks_operation_dispatch(current.family, current.opcode, inputs, current.input_count, &slots[current.output_slot]);
                __syncthreads();
            }
        }
        """;
#pragma warning restore MA0136

    private readonly IntPtr module;
    private readonly IntPtr function;
    private readonly IntPtr started;
    private readonly IntPtr finished;

    /// <summary>Initializes the driver, compiles the dispatch kernel after the device module and loads it.</summary>
    internal VectorBlockDevice()
    {
        VectorBlockDriver.Initialize();
        var ptx = MathBlockCudaDeviceModule.CompilePtx(KernelSource, "proof-vector-blocks.cu");
        VectorBlockDriver.Require(VectorBlockDriver.cuModuleLoadData(out module, ptx), "cuModuleLoadData");
        VectorBlockDriver.Require(VectorBlockDriver.cuModuleGetFunction(out function, module, KernelName), "cuModuleGetFunction");
        VectorBlockDriver.Require(VectorBlockDriver.cuEventCreate(out started, 0), "cuEventCreate");
        VectorBlockDriver.Require(VectorBlockDriver.cuEventCreate(out finished, 0), "cuEventCreate");
    }

    /// <summary>
    /// Plans every dispatch of the call for the operand rows, builds the slot arena (the slots, their payloads and the scratch the plans ask for), uploads it once and returns the run.
    /// The outputs start as valid empty slots, which is what PatternResearcher's InitializeOutput writes before the dispatch.
    /// </summary>
    internal VectorBlockRun Prepare(VectorBlockCall call, double[] first, double[] second)
    {
        var inputs = new MathBlockValue[call.Contracts.Length][];
        for (var step = 0; step < inputs.Length; step++)
            inputs[step] = VectorBlockCalls.Inputs(call, step, first, second);
        return new VectorBlockRun(this, call, inputs);
    }

    /// <summary>Waits for the launches and returns the elapsed time of the launches since <see cref="Begin"/>, in nanoseconds.</summary>
    internal double End()
    {
        VectorBlockDriver.Require(VectorBlockDriver.cuEventRecord(finished, IntPtr.Zero), "cuEventRecord");
        VectorBlockDriver.Require(VectorBlockDriver.cuEventSynchronize(finished), "cuEventSynchronize");
        VectorBlockDriver.Require(VectorBlockDriver.cuEventElapsedTime(out var milliseconds, started, finished), "cuEventElapsedTime");
        return milliseconds * 1_000_000d;
    }

    /// <summary>Records the start event on the default stream.</summary>
    internal void Begin() => VectorBlockDriver.Require(VectorBlockDriver.cuEventRecord(started, IntPtr.Zero), "cuEventRecord");

    /// <summary>Launches the dispatch kernel for one run: one block of the dispatcher block size.</summary>
    internal void Launch(IntPtr arguments) => VectorBlockDriver.Require(
        VectorBlockDriver.cuLaunchKernel(function, 1, 1, 1, (uint)MathBlockCudaDeviceModule.DispatcherBlockSize, 1, 1, 0, IntPtr.Zero, arguments, IntPtr.Zero),
        "cuLaunchKernel");

    /// <summary>Waits for every launched kernel.</summary>
    internal static void Synchronize() => VectorBlockDriver.Require(VectorBlockDriver.cuStreamSynchronize(IntPtr.Zero), "cuStreamSynchronize");

    /// <summary>Releases the events and the module.</summary>
    public void Dispose()
    {
        _ = VectorBlockDriver.cuEventDestroy(started);
        _ = VectorBlockDriver.cuEventDestroy(finished);
        if (module != IntPtr.Zero)
            _ = VectorBlockDriver.cuModuleUnload(module);
    }
}
