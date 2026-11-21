using System.Runtime.InteropServices;
using Supprocom.MathBlocks.Cuda;
using Driver = Supprocom.MathBlocks.Tests.MathBlockCudaWorkerTestsBaseOpcodeDispatch.CudaDriver;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Calls <c>mathblocks_elementwise_row</c> from a consumer-owned kernel for every elementwise source in both forms and both opcode encodings,
/// on a grid of finite, non-finite, signed-zero and subnormal arguments, and compares the rows bit for bit with the dispatch's output for the
/// same inputs, computed by the same kernel.
/// </summary>
public sealed class MathBlockElementwiseRowDeviceTests
{
    private const float Fill = -98_765.25f;
    private const int SourceCount = 53;
    private const int Block = 128;

    // NVRTC ignores source line endings; this is not a fingerprinted fixture.
#pragma warning disable MA0136
    private const string Kernel = """
        __device__ void row_probe_slot(MathBlockSlot* slot, const double* data, int rows, int valid)
        {
            slot->scalar_value = 0.0;
            slot->data_pointer = (unsigned long long)data;
            slot->scratch_pointer = 0ull;
            slot->boolean_value = 0;
            slot->valid = valid;
            slot->rows = data ? rows : 0;
            slot->columns = 0;
            slot->count = data ? rows : 0;
            slot->capacity = rows;
        }

        extern "C" __global__ void row_vs_dispatch(
            int source, int wide, double fill, int rows, const double* a, const double* b, const double* c,
            double* dispatch_values, int* dispatch_valid, double* row_values, int* row_valid)
        {
            __shared__ MathBlockSlot slots[6];
            __shared__ const MathBlockSlot* value_inputs[4];
            __shared__ const MathBlockSlot* valid_inputs[3];
            int arity = mathblocks_elementwise_source_arity(source);
            int values_opcode = (wide ? 1024 : 0) + 2 * source;
            int valid_opcode = values_opcode + 1;
            if (threadIdx.x == 0)
            {
                row_probe_slot(&slots[0], a, rows, 1);
                row_probe_slot(&slots[1], b, rows, 1);
                row_probe_slot(&slots[2], c, rows, 1);
                row_probe_slot(&slots[3], 0, rows, 1);
                slots[3].scalar_value = fill;
                row_probe_slot(&slots[4], dispatch_values, rows, 1);
                row_probe_slot(&slots[5], (const double*)dispatch_valid, rows, 1);
                for (int index = 0; index < arity; ++index)
                {
                    value_inputs[index] = &slots[index];
                    valid_inputs[index] = &slots[index];
                }
                value_inputs[arity] = &slots[3];
            }
            __syncthreads();
            mathblocks_operation_dispatch(12, values_opcode, value_inputs, arity + 1, &slots[4]);
            mathblocks_operation_dispatch(12, valid_opcode, valid_inputs, arity, &slots[5]);
            for (int row = threadIdx.x; row < rows; row += blockDim.x)
            {
                double value = 0.0;
                double ignored = 0.0;
                (void)mathblocks_elementwise_row(values_opcode, a[row], b[row], c[row], fill, &value);
                row_values[row] = value;
                row_valid[row] = mathblocks_elementwise_row(valid_opcode, a[row], b[row], c[row], fill, &ignored) ? 1 : 0;
            }
        }
        """;
#pragma warning restore MA0136

    private static readonly float[] Grid =
    [
        0f, -0f, 1f, -1f, 0.5f, -0.5f, 2f, 3f, 10f, -10f, 0.1f, 0.9f, 1.03e-37f, float.Epsilon, -float.Epsilon, 1e-10f, 1e10f, 3.16e37f, -3.16e37f,
        float.MaxValue, 0.25f, 100f, 7.5f, 1e5f, float.NaN, float.PositiveInfinity, float.NegativeInfinity, BitConverter.Int32BitsToSingle(unchecked((int)0xFFC00000u))
    ];

    // The launch and the resource lifetime stay in one visible path, as in the dispatch test.
#pragma warning disable MA0051
    /// <summary>Verifies the row function gives the dispatch's value, and its validity, for every source in both forms and both opcode encodings.</summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void CUDARowFunctionMatchesTheDispatchForEverySource()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var count = Grid.Length * Grid.Length * Grid.Length;
        var a = new float[count];
        var b = new float[count];
        var c = new float[count];
        for (var row = 0; row < count; row++)
        {
            a[row] = Grid[row % Grid.Length];
            b[row] = Grid[row / Grid.Length % Grid.Length];
            c[row] = Grid[row / (Grid.Length * Grid.Length)];
        }

        var module = IntPtr.Zero;
        var buffers = new List<ulong>();
        var host = new List<IntPtr>();
        try
        {
            Driver.Initialize();
            var ptx = MathBlockCudaDeviceModule.CompilePtx(Kernel, "elementwise-row-dispatch.cu");
            Driver.Require(Driver.cuModuleLoadData(out module, ptx), "cuModuleLoadData");
            Driver.Require(
                Driver.cuModuleGetFunction(out var function, module, "row_vs_dispatch"),
                "cuModuleGetFunction");

            var aDevice = Upload(a, buffers);
            var bDevice = Upload(b, buffers);
            var cDevice = Upload(c, buffers);
            var dispatchValues = Allocate(count * sizeof(float), buffers);
            var dispatchValid = Allocate(count * sizeof(int), buffers);
            var rowValues = Allocate(count * sizeof(float), buffers);
            var rowValid = Allocate(count * sizeof(int), buffers);
            var hostValues = Marshal.AllocHGlobal(count * sizeof(float));
            var hostValid = Marshal.AllocHGlobal(count * sizeof(int));
            host.Add(hostValues);
            host.Add(hostValid);
            var mismatches = new List<string>();
            for (var source = 0; source < SourceCount; source++)
            {
                for (var wide = 0; wide < 2; wide++)
                {
                    IntPtr[] arguments =
                    [
                        Box(source, host), Box(wide, host), Box(Fill, host), Box(count, host), Box(aDevice, host), Box(bDevice, host), Box(cDevice, host),
                        Box(dispatchValues, host), Box(dispatchValid, host), Box(rowValues, host), Box(rowValid, host)
                    ];
                    var parameterArray = Marshal.AllocHGlobal(arguments.Length * IntPtr.Size);
                    host.Add(parameterArray);
                    for (var index = 0; index < arguments.Length; index++)
                        Marshal.WriteIntPtr(parameterArray, index * IntPtr.Size, arguments[index]);
                    Driver.Require(
                        Driver.cuLaunchKernel(function, 1, 1, 1, Block, 1, 1, 0, IntPtr.Zero, parameterArray, IntPtr.Zero),
                        "cuLaunchKernel");
                    Driver.Require(
                        Driver.cuStreamSynchronize(IntPtr.Zero),
                        "cuStreamSynchronize");

                    var expectedValues = DownloadLongs(dispatchValues, count, hostValues);
                    var actualValues = DownloadLongs(rowValues, count, hostValues);
                    var expectedValid = DownloadInts(dispatchValid, count, hostValid);
                    var actualValid = DownloadInts(rowValid, count, hostValid);
                    for (var row = 0; row < count && mismatches.Count < 20; row++)
                    {
                        if (expectedValues[row] != actualValues[row] || expectedValid[row] != actualValid[row])
                            mismatches.Add($"source {source} wide {wide} row {row} ({a[row]:R}, {b[row]:R}, {c[row]:R}): dispatch {BitConverter.Int64BitsToDouble(expectedValues[row]):R}/{expectedValid[row]}, row {BitConverter.Int64BitsToDouble(actualValues[row]):R}/{actualValid[row]}");
                    }
                }
            }

            Assert.Empty(mismatches);
        }
        finally
        {
            for (var index = 0; index < host.Count; index++)
                Marshal.FreeHGlobal(host[index]);
            for (var index = 0; index < buffers.Count; index++)
                _ = Driver.cuMemFree(buffers[index]);
            if (module != IntPtr.Zero)
                _ = Driver.cuModuleUnload(module);
        }
    }

#pragma warning restore MA0051

    private static ulong Allocate(int bytes, List<ulong> buffers)
    {
        Driver.Require(Driver.cuMemAlloc(out var pointer, new UIntPtr((uint)bytes)), "cuMemAlloc");
        buffers.Add(pointer);
        return pointer;
    }

    private static ulong Upload(float[] values, List<ulong> buffers)
    {
        var pointer = Allocate(values.Length * sizeof(float), buffers);
        var staging = Marshal.AllocHGlobal(values.Length * sizeof(float));
        try
        {
            Marshal.Copy(values, 0, staging, values.Length);
            Driver.Require(
                Driver.cuMemcpyHtoD(pointer, staging, new UIntPtr((uint)(values.Length * sizeof(float)))),
                "cuMemcpyHtoD");
        }
        finally
        {
            Marshal.FreeHGlobal(staging);
        }

        return pointer;
    }

    private static long[] DownloadLongs(ulong device, int count, IntPtr staging)
    {
        Driver.Require(Driver.cuMemcpyDtoH(staging, device, new UIntPtr((uint)(count * sizeof(long)))), "cuMemcpyDtoH");
        var result = new long[count];
        Marshal.Copy(staging, result, 0, count);
        return result;
    }

    private static int[] DownloadInts(ulong device, int count, IntPtr staging)
    {
        Driver.Require(Driver.cuMemcpyDtoH(staging, device, new UIntPtr((uint)(count * sizeof(int)))), "cuMemcpyDtoH");
        var result = new int[count];
        Marshal.Copy(staging, result, 0, count);
        return result;
    }

    private static IntPtr Box(int value, List<IntPtr> host)
    {
        var pointer = Marshal.AllocHGlobal(sizeof(int));
        Marshal.WriteInt32(pointer, value);
        host.Add(pointer);
        return pointer;
    }

    private static IntPtr Box(float value, List<IntPtr> host)
    {
        var pointer = Marshal.AllocHGlobal(sizeof(float));
        Marshal.WriteInt64(pointer, BitConverter.SingleToInt32Bits(value));
        host.Add(pointer);
        return pointer;
    }

    private static IntPtr Box(ulong value, List<IntPtr> host)
    {
        var pointer = Marshal.AllocHGlobal(sizeof(ulong));
        Marshal.WriteInt64(pointer, unchecked((long)value));
        host.Add(pointer);
        return pointer;
    }
}
