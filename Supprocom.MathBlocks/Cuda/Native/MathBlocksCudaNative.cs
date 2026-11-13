using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;

namespace Supprocom.MathBlocks.Cuda;

internal static class MathBlocksCudaNative
{
    private static readonly Lock contextLock = new();
    private static readonly Dictionary<int, IntPtr> primaryContexts = new();

    // Logical import name; the resolver maps it to the NVRTC that MathBlocksNvrtcLoader found.
    private const string Nvrtc = "nvrtc";

    static MathBlocksCudaNative()
    {
        NativeLibrary.SetDllImportResolver(typeof(MathBlocksCudaNative).Assembly, ResolveNativeLibrary);
    }

    public static bool IsAvailable()
    {
        try
        {
            EnsureContext(0);
            return true;
        }
        // Availability is a non-throwing probe across driver/load/runtime failures.
#pragma warning disable CA1031
        catch
        {
            return false;
        }
#pragma warning restore CA1031
    }

    // The primary context of the device with the given ordinal, made current on the calling thread.
    public static IntPtr ContextFor(int ordinal)
    {
        EnsureContext(ordinal);
        lock (contextLock)
            return primaryContexts[ordinal];
    }

    public static int cuMemAllocHost(out IntPtr pointer, UIntPtr bytes) =>
        cuMemHostAlloc(out pointer, bytes, 0);

    // Makes the primary context of the device with the given ordinal current on the calling thread. The ordinal is checked
    // against the number of CUDA devices, and the error names that number.
    public static void EnsureContext(int ordinal)
    {
        lock (contextLock)
        {
            ThrowIfFailed(cuInit(0), "cuInit");
            if (!primaryContexts.TryGetValue(ordinal, out var context))
            {
                var device = GetDevice(ordinal);
                ThrowIfFailed(cuDevicePrimaryCtxRetain(out context, device), "cuDevicePrimaryCtxRetain");
                primaryContexts.Add(ordinal, context);
            }
            ThrowIfFailed(cuCtxSetCurrent(context), "cuCtxSetCurrent");
        }
    }

    // The device handle for an ordinal from 0 up to the device count; any other ordinal is an ArgumentOutOfRangeException that
    // names the count. cuInit has run.
    internal static int GetDevice(int ordinal)
    {
        ThrowIfFailed(cuDeviceGetCount(out var count), "cuDeviceGetCount");
        if (ordinal < 0 || ordinal >= count)
        {
            throw MathBlocksCudaOptionsValidator.DeviceOrdinalOutOfRange(ordinal, count);
        }

        ThrowIfFailed(cuDeviceGet(out var device, ordinal), "cuDeviceGet");
        return device;
    }

    // The limits of the device with the given ordinal: CU_DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK (1) and
    // CU_DEVICE_ATTRIBUTE_MAX_GRID_DIM_X (5).
    public static MathBlockCudaDeviceLimits GetDeviceLimits(int ordinal)
    {
        EnsureContext(ordinal);
        var device = GetDevice(ordinal);
        ThrowIfFailed(cuDeviceGetAttribute(out var threads, 1, device), "cuDeviceGetAttribute(max threads per block)");
        ThrowIfFailed(cuDeviceGetAttribute(out var grid, 5, device), "cuDeviceGetAttribute(max grid dim x)");
        return new MathBlockCudaDeviceLimits(threads, grid);
    }

    // CU_FUNC_ATTRIBUTE_MAX_THREADS_PER_BLOCK (0): the most threads per block this compiled kernel can launch with.
    public static int GetKernelMaximumThreadsPerBlock(IntPtr function)
    {
        ThrowIfFailed(cuFuncGetAttribute(out var threads, 0, function), "cuFuncGetAttribute(max threads per block)");
        return threads;
    }

    public static byte[] CompilePtx(string source, string name) => CompilePtx(source, name, 0);

    // For the architecture of the device with the given ordinal.
    public static byte[] CompilePtx(string source, string name, int ordinal)
    {
        EnsureContext(ordinal);
        return CompilePtxForArchitecture(source, name, ResolvePtxArchitecture(ordinal));
    }

    // Compiles with --fmad=true or --fmad=false, for checks that code written with explicit rounding intrinsics
    // keeps its bits under either contraction setting a consumer may choose.
    public static byte[] CompilePtx(string source, string name, bool fusedMultiplyAdd) =>
        CompilePtx(source, name, fusedMultiplyAdd, 0);

    public static byte[] CompilePtx(string source, string name, bool fusedMultiplyAdd, int ordinal)
    {
        EnsureContext(ordinal);
        return CompileForArchitecture(source, name, ResolvePtxArchitecture(ordinal), fusedMultiplyAdd);
    }

    // Compiles for a fixed architecture, as production does (--fmad=false), without a context or a device. For the PTX
    // allow-list test, which runs where NVRTC is installed and no CUDA device is.
    internal static byte[] CompilePtxWithoutDevice(string source, string name, string architecture) =>
        CompileForArchitecture(source, name, architecture, fusedMultiplyAdd: false);

    private static byte[] CompilePtxForArchitecture(string source, string name, string architecture) =>
        CompileForArchitecture(source, name, architecture, fusedMultiplyAdd: false);

    private static byte[] CompileForArchitecture(
        string source,
        string name,
        string architecture,
        bool fusedMultiplyAdd)
    {
        // Loads NVRTC, or throws the requirement message, before the first NVRTC import binds.
        _ = MathBlocksNvrtcLoader.Library;
        ThrowIfFailed(nvrtcCreateProgram(out var program, source, name, 0, IntPtr.Zero, IntPtr.Zero), "nvrtcCreateProgram");
        try
        {
            var options = new[]
            {
                $"--gpu-architecture={architecture}",
                fusedMultiplyAdd ? "--fmad=true" : "--fmad=false",
                "--prec-div=true",
                "--prec-sqrt=true"
            };
            var result = CompileWithUtf8Options(program, options);
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

    private static NvrtcResult CompileWithUtf8Options(IntPtr program, string[] options)
    {
        // The runtime cannot marshal string[] with an LPUTF8Str array subtype.
        // NVRTC consumes these UTF-8 pointers synchronously during compilation.
        var pointers = new IntPtr[options.Length];
        try
        {
            for (var index = 0; index < options.Length; index++)
                pointers[index] = Marshal.StringToCoTaskMemUTF8(options[index]);
            return nvrtcCompileProgram(program, pointers.Length, pointers);
        }
        finally
        {
            foreach (var pointer in pointers)
                if (pointer != IntPtr.Zero)
                    Marshal.FreeCoTaskMem(pointer);
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

    private static string ResolvePtxArchitecture(int ordinal)
    {
        var device = GetDevice(ordinal);
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
        if (string.Equals(libraryName, Nvrtc, StringComparison.Ordinal))
            return MathBlocksNvrtcLoader.TryGetHandle(out var nvrtc) ? nvrtc : IntPtr.Zero;
        if (OperatingSystem.IsWindows())
            return IntPtr.Zero;
        if (string.Equals(libraryName, "nvcuda.dll", StringComparison.Ordinal))
            return LoadNativeLibrary("libcuda.so.1", "libcuda.so");
        return IntPtr.Zero;
    }

    private static IntPtr LoadNativeLibrary(params string[] names)
    {
        foreach (var name in names)
            if (NativeLibrary.TryLoad(name, out var handle))
                return handle;
        return IntPtr.Zero;
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
    internal static extern int cuDeviceGetCount(out int count);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuDeviceGetAttribute(out int value, int attribute, int device);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuFuncGetAttribute(out int value, int attribute, IntPtr function);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuDevicePrimaryCtxRetain(out IntPtr context, int device);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuCtxSetCurrent(IntPtr context);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuModuleLoadData(out IntPtr module, byte[] image);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi,
        BestFitMapping = false, ThrowOnUnmappableChar = true)]
    internal static extern int cuModuleGetFunction(
        out IntPtr function,
        IntPtr module,
        [MarshalAs(UnmanagedType.LPUTF8Str)] string name);

    [DllImport("nvcuda.dll", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuModuleUnload(IntPtr module);

    [DllImport("nvcuda.dll", EntryPoint = "cuModuleGetGlobal_v2", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi,
        BestFitMapping = false, ThrowOnUnmappableChar = true)]
    internal static extern int cuModuleGetGlobal(
        out ulong devicePointer,
        out UIntPtr bytes,
        IntPtr module,
        [MarshalAs(UnmanagedType.LPUTF8Str)] string name);

    [DllImport("nvcuda.dll", EntryPoint = "cuMemcpyDtoH_v2", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuMemcpyDtoH(IntPtr destination, ulong source, UIntPtr bytes);

    [DllImport("nvcuda.dll", EntryPoint = "cuMemsetD8Async", CallingConvention = CallingConvention.Cdecl)]
    internal static extern int cuMemsetD8OnStream(ulong devicePointer, byte value, UIntPtr count, IntPtr stream);

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

    [DllImport(Nvrtc, CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi,
        BestFitMapping = false, ThrowOnUnmappableChar = true)]
    private static extern NvrtcResult nvrtcCreateProgram(
        out IntPtr program,
        [MarshalAs(UnmanagedType.LPUTF8Str)] string source,
        [MarshalAs(UnmanagedType.LPUTF8Str)] string name,
        int headerCount,
        IntPtr headers,
        IntPtr includeNames);

    [DllImport(Nvrtc, CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi,
        BestFitMapping = false, ThrowOnUnmappableChar = true)]
    private static extern NvrtcResult nvrtcCompileProgram(
        IntPtr program,
        int optionCount,
        [In, MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 1)] IntPtr[] options);

    [DllImport(Nvrtc, CallingConvention = CallingConvention.Cdecl)]
    private static extern NvrtcResult nvrtcGetPTXSize(IntPtr program, out UIntPtr size);

    [DllImport(Nvrtc, CallingConvention = CallingConvention.Cdecl)]
    private static extern NvrtcResult nvrtcGetPTX(IntPtr program, byte[] ptx);

    [DllImport(Nvrtc, CallingConvention = CallingConvention.Cdecl)]
    private static extern NvrtcResult nvrtcGetProgramLogSize(IntPtr program, out UIntPtr size);

    [DllImport(Nvrtc, CallingConvention = CallingConvention.Cdecl)]
    private static extern NvrtcResult nvrtcGetProgramLog(IntPtr program, byte[] log);

    [DllImport(Nvrtc, CallingConvention = CallingConvention.Cdecl)]
    private static extern NvrtcResult nvrtcDestroyProgram(ref IntPtr program);
}
