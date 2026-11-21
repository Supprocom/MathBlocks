using System.Globalization;
using System.Runtime.InteropServices;
using System.Text;
using Supprocom.MathBlocks.Cuda;
using Driver = Supprocom.MathBlocks.Tests.MathBlockCudaWorkerTestsBaseOpcodeDispatch.CudaDriver;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Calls every <c>mathblocks_row_&lt;operation&gt;</c> function from a consumer-owned kernel on a grid of finite, non-finite, signed-zero and subnormal arguments and compares
/// the value, bit for bit, and the validity with the scalar dispatch's output for the same inputs, computed by the same kernel. An argument that is not finite gives the dispatch an
/// invalid input slot, as a host's validity does; the values are compared where the row is valid.
/// </summary>
public sealed class MathBlockRowFunctionDeviceTests
{
    private const float Fill = -98_765.25f;
    private const int ScalarFamily = 6;

    private static readonly float[] Grid =
    [
        0f, -0f, 1f, -1f, 0.5f, -0.5f, 2f, 3f, 10f, -10f, 0.1f, 0.9f, 1.03e-37f, float.Epsilon, -float.Epsilon, 1e-10f, 1e10f, 3.16e37f, -3.16e37f,
        float.MaxValue, -float.MaxValue, 0.25f, 100f, 7.5f, 1e5f, float.NaN, float.PositiveInfinity, float.NegativeInfinity, BitConverter.Int32BitsToSingle(unchecked((int)0xFFC00000u))
    ];

    // The kernel text is assembled from raw strings; NVRTC ignores their line endings, and the kernel is not a fingerprinted fixture.
#pragma warning disable MA0051, MA0136
    /// <summary>Gets the source of the consumer kernel that runs one operation, by its index in the function table, through the scalar dispatch and through its row function.</summary>
    internal static string Kernel()
    {
        var text = new StringBuilder();
        text.Append("""
            __device__ void row_scalar_slot(MathBlockSlot* slot, float value)
            {
                slot->scalar_value = value;
                slot->data_pointer = 0ull;
                slot->scratch_pointer = 0ull;
                slot->boolean_value = value != 0.0f ? 1 : 0;
                slot->valid = isfinite(value) ? 1 : 0;
                slot->rows = 0;
                slot->columns = 0;
                slot->count = 0;
                slot->capacity = 0;
            }

            extern "C" __global__ void row_vs_dispatch(
                int op, int rows, float fill, const float* a, const float* b, const float* c,
                float* dispatch_values, int* dispatch_valid, float* row_values, int* row_valid)
            {
                if (threadIdx.x != 0 || blockIdx.x != 0)
                    return;
                int opcode = 0;
                int arity = 0;
                switch (op)
                {

            """);
        var functions = MathBlockRowFunctionTests.Functions;
        for (var index = 0; index < functions.Length; index++)
        {
            var function = functions[index];
            text.Append("        case ").Append(index.ToString(CultureInfo.InvariantCulture)).Append(": opcode = ").Append(function.Opcode.ToString(CultureInfo.InvariantCulture))
                .Append("; arity = ").Append(function.Arity.ToString(CultureInfo.InvariantCulture)).Append("; break;\n");
        }

        text.Append("""
                    default: return;
                }
                for (int row = 0; row < rows; ++row)
                {
                    MathBlockSlot first;
                    MathBlockSlot second;
                    MathBlockSlot third;
                    MathBlockSlot output;
                    row_scalar_slot(&first, a[row]);
                    row_scalar_slot(&second, b[row]);
                    row_scalar_slot(&third, c[row]);
                    row_scalar_slot(&output, 0.0f);
                    const MathBlockSlot* inputs[3] = { &first, &second, &third };
                    mathblocks_operation_dispatch(
            """);
        text.Append(ScalarFamily.ToString(CultureInfo.InvariantCulture));
        text.Append("""
            , opcode, inputs, arity, &output);
                    dispatch_valid[row] = output.valid ? 1 : 0;
                    dispatch_values[row] = output.scalar_value;
                    float value = 0.0f;
                    float x = a[row];
                    float y = b[row];
                    float z = c[row];
                    bool ok = false;
                    (void)y;
                    (void)z;
                    switch (op)
                    {

            """);
        for (var index = 0; index < functions.Length; index++)
        {
            var function = functions[index];
            var arguments = function.Arity == 1 ? "x" : function.Arity == 2 ? "x, y" : "x, y, z";
            text.Append("            case ").Append(index.ToString(CultureInfo.InvariantCulture)).Append(": ok = mathblocks_row_").Append(function.Operation)
                .Append('(').Append(arguments).Append(", fill, &value); break;\n");
        }

        text.Append("""
                        default: break;
                    }
                    row_valid[row] = ok ? 1 : 0;
                    row_values[row] = value;
                }
            }

            """);
        return text.ToString();
    }

    // The launch and the resource lifetime stay in one visible path, as in the dispatch test.
    /// <summary>Verifies every row function gives the scalar dispatch's value bit for bit, and its validity, on the grid of arguments.</summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void CUDARowFunctionsMatchTheScalarDispatch()
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
            var ptx = MathBlockCudaDeviceModule.CompilePtx(Kernel(), "row-functions-dispatch.cu");
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
            var functions = MathBlockRowFunctionTests.Functions;
            for (var op = 0; op < functions.Length; op++)
            {
                IntPtr[] arguments =
                [
                    Box(op, host), Box(count, host), Box(Fill, host), Box(aDevice, host), Box(bDevice, host), Box(cDevice, host),
                    Box(dispatchValues, host), Box(dispatchValid, host), Box(rowValues, host), Box(rowValid, host)
                ];
                var parameterArray = Marshal.AllocHGlobal(arguments.Length * IntPtr.Size);
                host.Add(parameterArray);
                for (var index = 0; index < arguments.Length; index++)
                    Marshal.WriteIntPtr(parameterArray, index * IntPtr.Size, arguments[index]);
                Driver.Require(
                    Driver.cuLaunchKernel(function, 1, 1, 1, 1, 1, 1, 0, IntPtr.Zero, parameterArray, IntPtr.Zero),
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
                    var valueDiffers = expectedValid[row] != 0 && expectedValues[row] != actualValues[row];
                    if (valueDiffers || expectedValid[row] != actualValid[row])
                        mismatches.Add($"{functions[op].Operation} row {row} ({a[row]:R}, {b[row]:R}, {c[row]:R}): dispatch {BitConverter.Int64BitsToDouble(expectedValues[row]):R}/{expectedValid[row]}, row {BitConverter.Int64BitsToDouble(actualValues[row]):R}/{actualValid[row]}");
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

#pragma warning restore MA0051, MA0136

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

    // The values are single precision, 32 bits each; their bit patterns are returned widened.
    private static long[] DownloadLongs(ulong device, int count, IntPtr staging)
    {
        Driver.Require(Driver.cuMemcpyDtoH(staging, device, new UIntPtr((uint)(count * sizeof(int)))), "cuMemcpyDtoH");
        var bits = new int[count];
        Marshal.Copy(staging, bits, 0, count);
        return Array.ConvertAll(bits, value => (long)value);
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
        Marshal.WriteInt32(pointer, BitConverter.SingleToInt32Bits(value));
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
