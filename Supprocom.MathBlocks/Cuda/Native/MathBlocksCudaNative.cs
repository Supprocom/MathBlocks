using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;

namespace Supprocom.MathBlocks.Cuda;

internal static class MathBlocksCudaNative
{
    private static readonly object contextLock = new();
    private static IntPtr primaryContext;

    static MathBlocksCudaNative()
    {
        NativeLibrary.SetDllImportResolver(typeof(MathBlocksCudaNative).Assembly, ResolveNativeLibrary);
        if (OperatingSystem.IsWindows())
        {
            var nativeDirectory = Path.Combine(AppContext.BaseDirectory, "runtimes", "win-x64", "native");
            if (Directory.Exists(nativeDirectory))
                _ = Kernel32.SetDllDirectory(nativeDirectory);
        }
    }

    public static bool IsAvailable()
    {
        try
        {
            EnsureContext();
            return true;
        }
        catch
        {
            return false;
        }
    }

    public static IntPtr CurrentContext
    {
        get
        {
            EnsureContext();
            return primaryContext;
        }
    }

    public static int cuMemAllocHost(out IntPtr pointer, UIntPtr bytes) =>
        cuMemHostAlloc(out pointer, bytes, 0);

    public static void EnsureContext()
    {
        lock (contextLock)
        {
            ThrowIfFailed(cuInit(0), "cuInit");
            if (primaryContext == IntPtr.Zero)
            {
                ThrowIfFailed(cuDeviceGet(out var device, 0), "cuDeviceGet");
                ThrowIfFailed(cuDevicePrimaryCtxRetain(out primaryContext, device), "cuDevicePrimaryCtxRetain");
            }
            ThrowIfFailed(cuCtxSetCurrent(primaryContext), "cuCtxSetCurrent");
        }
    }

    public static byte[] CompilePtx(string source, string name)
    {
        EnsureContext();
        ThrowIfFailed(nvrtcCreateProgram(out var program, source, name, 0, null, null), "nvrtcCreateProgram");
        try
        {
            var options = new[]
            {
                $"--gpu-architecture={ResolvePtxArchitecture()}",
                "--fmad=false",
                "--prec-div=true",
                "--prec-sqrt=true"
            };
            var result = nvrtcCompileProgram(program, options.Length, options);
            if (result != NvrtcResult.Success)
                throw new InvalidOperationException($"NVRTC failed: {result}. {GetProgramLog(program)}");

            ThrowIfFailed(nvrtcGetPTXSize(program, out var size), "nvrtcGetPTXSize");
            var ptx = GC.AllocateUninitializedArray<byte>(checked((int)size));
            ThrowIfFailed(nvrtcGetPTX(program, ptx), "nvrtcGetPTX");
            return ptx;
        }
        finally
        {
            _ = nvrtcDestroyProgram(ref program);
        }
    }

    public static void ThrowIfFailed(int result, string operation)
    {
        if (result != 0)
            throw new InvalidOperationException($"{operation} failed with CUDA result {result}.");
    }

    private static void ThrowIfFailed(NvrtcResult result, string operation)
    {
        if (result != NvrtcResult.Success)
            throw new InvalidOperationException($"{operation} failed with NVRTC result {result}.");
    }

    private static string ResolvePtxArchitecture()
    {
        ThrowIfFailed(cuDeviceGet(out var device, 0), "cuDeviceGet");
        ThrowIfFailed(cuDeviceGetAttribute(out var major, 75, device), "cuDeviceGetAttribute(major)");
        ThrowIfFailed(cuDeviceGetAttribute(out var minor, 76, device), "cuDeviceGetAttribute(minor)");
        return $"compute_{major}{minor}";
    }

    private static string GetProgramLog(IntPtr program)
    {
        _ = nvrtcGetProgramLogSize(program, out var size);
        var bytes = new byte[(int)size];
        _ = nvrtcGetProgramLog(program, bytes);
        return Encoding.UTF8.GetString(bytes).TrimEnd('\0');
    }

    private static IntPtr ResolveNativeLibrary(
        string libraryName,
        Assembly assembly,
        DllImportSearchPath? searchPath)
    {
        if (OperatingSystem.IsWindows())
            return IntPtr.Zero;
        if (string.Equals(libraryName, "nvcuda.dll", StringComparison.Ordinal))
            return LoadNativeLibrary("libcuda.so.1", "libcuda.so");
        if (string.Equals(libraryName, "nvrtc64_120_0.dll", StringComparison.Ordinal))
            return LoadNativeLibrary("libnvrtc.so.13", "libnvrtc.so.12", "libnvrtc.so");
        return IntPtr.Zero;
    }

    private static IntPtr LoadNativeLibrary(params string[] names)
    {
        foreach (var name in names)
            if (NativeLibrary.TryLoad(name, out var handle))
                return handle;
        return IntPtr.Zero;
    }

    private static class Kernel32
    {
        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool SetDllDirectory(string directory);
    }

    internal enum NvrtcResult
    {
        Success = 0
    }

    [StructLayout(LayoutKind.Sequential)]
    internal struct KernelNodeParameters
    {
        public IntPtr Function;
        public uint GridX;
        public uint GridY;
        public uint GridZ;
        public uint BlockX;
        public uint BlockY;
        public uint BlockZ;
        public uint SharedMemoryBytes;
        public IntPtr KernelParameters;
        public IntPtr Extra;
    }

    internal enum MemoryType
    {
        Host = 1,
        Device = 2
    }

    [StructLayout(LayoutKind.Sequential)]
    internal struct MemoryCopy3D
    {
        public UIntPtr SourceXInBytes;
        public UIntPtr SourceY;
        public UIntPtr SourceZ;
        public UIntPtr SourceLevelOfDetail;
        public MemoryType SourceMemoryType;
        public IntPtr SourceHost;
        public ulong SourceDevice;
        public IntPtr SourceArray;
        public IntPtr Reserved0;
        public UIntPtr SourcePitch;
        public UIntPtr SourceHeight;
        public UIntPtr DestinationXInBytes;
        public UIntPtr DestinationY;
        public UIntPtr DestinationZ;
        public UIntPtr DestinationLevelOfDetail;
        public MemoryType DestinationMemoryType;
        public IntPtr DestinationHost;
        public ulong DestinationDevice;
        public IntPtr DestinationArray;
        public IntPtr Reserved1;
        public UIntPtr DestinationPitch;
        public UIntPtr DestinationHeight;
        public UIntPtr WidthInBytes;
        public UIntPtr Height;
        public UIntPtr Depth;

        public static MemoryCopy3D HostToDevice(IntPtr source, ulong destination, int bytes)
        {
            var size = new UIntPtr(checked((uint)bytes));
            return new MemoryCopy3D
            {
                SourceMemoryType = MemoryType.Host,
                SourceHost = source,
                SourcePitch = size,
                SourceHeight = new UIntPtr(1),
                DestinationMemoryType = MemoryType.Device,
                DestinationDevice = destination,
                DestinationPitch = size,
                DestinationHeight = new UIntPtr(1),
                WidthInBytes = size,
                Height = new UIntPtr(1),
                Depth = new UIntPtr(1)
            };
        }

        public static MemoryCopy3D DeviceToHost(ulong source, IntPtr destination, int bytes)
        {
            var size = new UIntPtr(checked((uint)bytes));
            return new MemoryCopy3D
            {
                SourceMemoryType = MemoryType.Device,
                SourceDevice = source,
                SourcePitch = size,
                SourceHeight = new UIntPtr(1),
                DestinationMemoryType = MemoryType.Host,
                DestinationHost = destination,
                DestinationPitch = size,
                DestinationHeight = new UIntPtr(1),
                WidthInBytes = size,
                Height = new UIntPtr(1),
                Depth = new UIntPtr(1)
            };
        }
    }

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuInit(uint flags);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuDeviceGet(out int device, int ordinal);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuDeviceGetAttribute(out int value, int attribute, int device);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuDevicePrimaryCtxRetain(out IntPtr context, int device);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuCtxSetCurrent(IntPtr context);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuModuleLoadData(out IntPtr module, byte[] image);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
    internal static extern int cuModuleGetFunction(out IntPtr function, IntPtr module, string name);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuModuleUnload(IntPtr module);

    [DllImport("nvcuda.dll", EntryPoint = "cuMemAlloc_v2", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuMemAlloc(out ulong devicePointer, UIntPtr bytes);

    [DllImport("nvcuda.dll", EntryPoint = "cuMemFree_v2", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuMemFree(ulong devicePointer);

    [DllImport("nvcuda.dll", EntryPoint = "cuMemcpyHtoD_v2", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuMemcpyHtoD(ulong destination, IntPtr source, UIntPtr bytes);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    private static extern int cuMemHostAlloc(out IntPtr pointer, UIntPtr bytes, uint flags);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuMemFreeHost(IntPtr pointer);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuStreamCreate(out IntPtr stream, uint flags);

    [DllImport("nvcuda.dll", EntryPoint = "cuStreamDestroy_v2", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuStreamDestroy(IntPtr stream);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuStreamSynchronize(IntPtr stream);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuGraphCreate(out IntPtr graph, uint flags);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuGraphAddKernelNode(
        out IntPtr graphNode,
        IntPtr graph,
        [In] IntPtr[]? dependencies,
        UIntPtr dependencyCount,
        ref KernelNodeParameters parameters);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuGraphAddMemcpyNode(
        out IntPtr graphNode,
        IntPtr graph,
        [In] IntPtr[]? dependencies,
        UIntPtr dependencyCount,
        ref MemoryCopy3D copyParameters,
        IntPtr context);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuGraphInstantiateWithFlags(out IntPtr executable, IntPtr graph, ulong flags);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuGraphLaunch(IntPtr executable, IntPtr stream);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuGraphExecDestroy(IntPtr executable);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuGraphDestroy(IntPtr graph);

    [DllImport("nvrtc64_120_0.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
    private static extern NvrtcResult nvrtcCreateProgram(
        out IntPtr program,
        string source,
        string name,
        int headerCount,
        string[]? headers,
        string[]? includeNames);

    [DllImport("nvrtc64_120_0.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
    private static extern NvrtcResult nvrtcCompileProgram(
        IntPtr program,
        int optionCount,
        [MarshalAs(UnmanagedType.LPArray, ArraySubType = UnmanagedType.LPStr)] string[] options);

    [DllImport("nvrtc64_120_0.dll", CallingConvention = CallingConvention.Cdecl)]
    private static extern NvrtcResult nvrtcGetPTXSize(IntPtr program, out UIntPtr size);

    [DllImport("nvrtc64_120_0.dll", CallingConvention = CallingConvention.Cdecl)]
    private static extern NvrtcResult nvrtcGetPTX(IntPtr program, byte[] ptx);

    [DllImport("nvrtc64_120_0.dll", CallingConvention = CallingConvention.Cdecl)]
    private static extern NvrtcResult nvrtcGetProgramLogSize(IntPtr program, out UIntPtr size);

    [DllImport("nvrtc64_120_0.dll", CallingConvention = CallingConvention.Cdecl)]
    private static extern NvrtcResult nvrtcGetProgramLog(IntPtr program, byte[] log);

    [DllImport("nvrtc64_120_0.dll", CallingConvention = CallingConvention.Cdecl)]
    private static extern NvrtcResult nvrtcDestroyProgram(ref IntPtr program);
}
