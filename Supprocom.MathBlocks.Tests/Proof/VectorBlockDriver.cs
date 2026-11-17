using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The CUDA driver calls of the vector-block proof, imported as nvcuda.dll like the other device tests (the test driver resolver maps the name on Linux). It adds the event calls that
/// the timing needs. The file has no test-framework dependency, so the 0.6.1 baseline console links it unchanged.
/// </summary>
internal static class VectorBlockDriver
{
    static VectorBlockDriver()
    {
        MathBlockCudaTestDriverResolver.Register();
    }

    /// <summary>Initializes the driver and makes the primary context of device 0 current.</summary>
    internal static void Initialize()
    {
        Require(cuInit(0), "cuInit");
        Require(cuDeviceGet(out var device, 0), "cuDeviceGet");
        Require(cuDevicePrimaryCtxRetain(out var context, device), "cuDevicePrimaryCtxRetain");
        Require(cuCtxSetCurrent(context), "cuCtxSetCurrent");
    }

    /// <summary>Throws when a driver call did not succeed.</summary>
    internal static void Require(int result, string operation)
    {
        if (result != 0)
            throw new InvalidOperationException(string.Create(System.Globalization.CultureInfo.InvariantCulture, $"{operation} failed with CUDA result {result}."));
    }

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuInit(uint flags);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuDeviceGet(out int device, int ordinal);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuDevicePrimaryCtxRetain(out IntPtr context, int device);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuCtxSetCurrent(IntPtr context);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuModuleLoadData(out IntPtr module, byte[] image);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi, BestFitMapping = false, ThrowOnUnmappableChar = true)]
    internal static extern int cuModuleGetFunction(out IntPtr function, IntPtr module, [MarshalAs(UnmanagedType.LPUTF8Str)] string name);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuModuleUnload(IntPtr module);

    [DllImport("nvcuda.dll", EntryPoint = "cuMemAlloc_v2", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuMemAlloc(out ulong devicePointer, UIntPtr bytes);

    [DllImport("nvcuda.dll", EntryPoint = "cuMemFree_v2", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuMemFree(ulong devicePointer);

    [DllImport("nvcuda.dll", EntryPoint = "cuMemcpyHtoD_v2", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuMemcpyHtoD(ulong destination, IntPtr source, UIntPtr bytes);

    [DllImport("nvcuda.dll", EntryPoint = "cuMemcpyDtoH_v2", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuMemcpyDtoH(IntPtr destination, ulong source, UIntPtr bytes);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuStreamSynchronize(IntPtr stream);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuEventCreate(out IntPtr eventHandle, uint flags);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuEventRecord(IntPtr eventHandle, IntPtr stream);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuEventSynchronize(IntPtr eventHandle);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuEventElapsedTime(out float milliseconds, IntPtr start, IntPtr end);

    [DllImport("nvcuda.dll", EntryPoint = "cuEventDestroy_v2", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuEventDestroy(IntPtr eventHandle);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuLaunchKernel(
        IntPtr function,
        uint gridX,
        uint gridY,
        uint gridZ,
        uint blockX,
        uint blockY,
        uint blockZ,
        uint sharedMemoryBytes,
        IntPtr stream,
        IntPtr kernelParameters,
        IntPtr extra);
}
