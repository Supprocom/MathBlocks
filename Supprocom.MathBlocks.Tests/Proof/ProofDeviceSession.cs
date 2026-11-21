using System.Runtime.InteropServices;
using Supprocom.MathBlocks.Cuda;
using Driver = Supprocom.MathBlocks.Tests.MathBlockCudaWorkerTestsBaseOpcodeDispatch.CudaDriver;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// A driver-API session for the proof kernels: it compiles a consumer kernel after the device module, loads it, owns the device buffers and the argument blocks of its launches,
/// and releases all of them when disposed. Launches are asynchronous on the default stream; <see cref="Synchronize"/> waits for them.
/// </summary>
internal sealed class ProofDeviceSession : IDisposable
{
    private const int Block = 256;
    private const int MaximumGrid = 65_535;

    private readonly List<ulong> buffers = [];
    private readonly List<IntPtr> host = [];
    private readonly IntPtr module;

    /// <summary>Compiles the consumer source after the device module and loads the result.</summary>
    internal ProofDeviceSession(string source, string name)
    {
        Driver.Initialize();
        var ptx = MathBlockCudaDeviceModule.CompilePtx(source, name);
        Driver.Require(Driver.cuModuleLoadData(out module, ptx), "cuModuleLoadData");
    }

    /// <summary>Waits for every launched kernel.</summary>
    internal static void Synchronize() => Driver.Require(Driver.cuStreamSynchronize(IntPtr.Zero), "cuStreamSynchronize");

    /// <summary>Gets a kernel of the loaded module by name.</summary>
    internal IntPtr Function(string name)
    {
        Driver.Require(Driver.cuModuleGetFunction(out var function, module, name), "cuModuleGetFunction");
        return function;
    }

    /// <summary>Allocates a device buffer that lives until the session is disposed.</summary>
    internal ulong Allocate(long bytes)
    {
        Driver.Require(Driver.cuMemAlloc(out var pointer, new UIntPtr((ulong)bytes)), "cuMemAlloc");
        buffers.Add(pointer);
        return pointer;
    }

    /// <summary>Copies the values to the device buffer.</summary>
    internal static void Upload(ulong device, float[] values)
    {
        var bytes = (long)values.Length * sizeof(float);
        var staging = Marshal.AllocHGlobal(new IntPtr(bytes));
        try
        {
            Marshal.Copy(values, 0, staging, values.Length);
            Driver.Require(Driver.cuMemcpyHtoD(device, staging, new UIntPtr((ulong)bytes)), "cuMemcpyHtoD");
        }
        finally
        {
            Marshal.FreeHGlobal(staging);
        }
    }

    /// <summary>Copies the first <paramref name="count"/> doubles of the device buffer back, as their bits.</summary>
    internal static long[] DownloadBits(ulong device, int count)
    {
        var staging = Marshal.AllocHGlobal(count * sizeof(long));
        try
        {
            Driver.Require(Driver.cuMemcpyDtoH(staging, device, new UIntPtr((ulong)count * sizeof(long))), "cuMemcpyDtoH");
            var result = new long[count];
            Marshal.Copy(staging, result, 0, count);
            return result;
        }
        finally
        {
            Marshal.FreeHGlobal(staging);
        }
    }

    /// <summary>Copies the first <paramref name="count"/> ints of the device buffer back.</summary>
    internal static int[] DownloadInts(ulong device, int count)
    {
        var staging = Marshal.AllocHGlobal(count * sizeof(int));
        try
        {
            Driver.Require(Driver.cuMemcpyDtoH(staging, device, new UIntPtr((ulong)count * sizeof(int))), "cuMemcpyDtoH");
            var result = new int[count];
            Marshal.Copy(staging, result, 0, count);
            return result;
        }
        finally
        {
            Marshal.FreeHGlobal(staging);
        }
    }

    /// <summary>Builds the argument block of a kernel from ints, doubles and device pointers (ulong); it is reused by every launch with the same arguments.</summary>
    internal IntPtr Arguments(params object[] values)
    {
        var block = Marshal.AllocHGlobal(values.Length * IntPtr.Size);
        host.Add(block);
        for (var index = 0; index < values.Length; index++)
        {
            var box = Marshal.AllocHGlobal(sizeof(long));
            host.Add(box);
            switch (values[index])
            {
                case int integer:
                    Marshal.WriteInt32(box, integer);
                    break;
                case float number:
                    Marshal.WriteInt64(box, BitConverter.SingleToInt32Bits(number));
                    break;
                case ulong pointer:
                    Marshal.WriteInt64(box, unchecked((long)pointer));
                    break;
                default:
                    throw new ArgumentException("A kernel argument must be an int, a double or a device pointer.", nameof(values));
            }

            Marshal.WriteIntPtr(block, index * IntPtr.Size, box);
        }

        return block;
    }

    /// <summary>Launches the kernel over the rows with a grid-stride loop's worth of blocks, without waiting.</summary>
    internal static void Launch(IntPtr function, IntPtr arguments, int rows)
    {
        var grid = (uint)Math.Clamp((rows + Block - 1) / Block, 1, MaximumGrid);
        Driver.Require(Driver.cuLaunchKernel(function, grid, 1, 1, Block, 1, 1, 0, IntPtr.Zero, arguments, IntPtr.Zero), "cuLaunchKernel");
    }

    /// <summary>Launches the kernel <paramref name="repeats"/> times back to back and waits once.</summary>
    internal static void LaunchBatch(IntPtr function, IntPtr arguments, int rows, int repeats)
    {
        for (var repeat = 0; repeat < repeats; repeat++)
            Launch(function, arguments, rows);
        Synchronize();
    }

    /// <summary>Frees the buffers, the argument blocks and the module.</summary>
    public void Dispose()
    {
        for (var index = 0; index < host.Count; index++)
            Marshal.FreeHGlobal(host[index]);
        for (var index = 0; index < buffers.Count; index++)
            _ = Driver.cuMemFree(buffers[index]);
        if (module != IntPtr.Zero)
            _ = Driver.cuModuleUnload(module);
    }
}
