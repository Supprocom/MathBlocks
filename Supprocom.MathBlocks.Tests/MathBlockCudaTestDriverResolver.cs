using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks.Tests;

// The one DllImport resolver of the test assembly for the CUDA driver library the device tests import as nvcuda.dll. A resolver can be set once per
// assembly, so every test driver wrapper registers through Register, which is idempotent.
internal static class MathBlockCudaTestDriverResolver
{
    private static readonly Lock Gate = new();
    private static bool registered;

    internal static void Register()
    {
        if (OperatingSystem.IsWindows())
            return;
        lock (Gate)
        {
            if (registered)
                return;
            NativeLibrary.SetDllImportResolver(typeof(MathBlockCudaTestDriverResolver).Assembly, Resolve);
            registered = true;
        }
    }

    private static IntPtr Resolve(string name, System.Reflection.Assembly assembly, DllImportSearchPath? searchPath)
    {
        if (!string.Equals(name, "nvcuda.dll", StringComparison.Ordinal))
            return IntPtr.Zero;
        if (NativeLibrary.TryLoad("libcuda.so.1", out var handle))
            return handle;
        return NativeLibrary.TryLoad("libcuda.so", out handle) ? handle : IntPtr.Zero;
    }
}
