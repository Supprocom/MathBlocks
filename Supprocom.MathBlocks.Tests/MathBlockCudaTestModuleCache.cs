using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Compiles a device module once per distinct compile input and keeps the loaded module for the cases of one test class. The key is a SHA-256 of the
/// full composed source (the MathBlocks device source for the domain options, then the consumer source), the source name and every NVRTC option, so a case
/// never runs against a module built for other inputs. Block size and launch options are launch-time values and are not part of the key. The cache
/// is thread-safe and unloads every module when it is disposed (a class fixture owns one).
/// </summary>
internal sealed class MathBlockCudaTestModuleCache : IDisposable
{
    private readonly Lock gate = new();
    private readonly Dictionary<string, (IntPtr Module, IntPtr Function)> entries = new(StringComparer.Ordinal);
    private readonly Action<IntPtr> unload;
    private bool disposed;

    /// <summary>Creates a cache that releases a loaded module with the given action.</summary>
    internal MathBlockCudaTestModuleCache(Action<IntPtr> unload)
    {
        ArgumentNullException.ThrowIfNull(unload);
        this.unload = unload;
    }

    /// <summary>Gets the number of loaded modules.</summary>
    internal int Count
    {
        get
        {
            lock (gate)
                return entries.Count;
        }
    }

    /// <summary>Gets the key of a compile: the composed source, the source name and the NVRTC options, each length-prefixed so no two inputs share a digest input.</summary>
    internal static string Key(string composedSource, string sourceName, IEnumerable<string> compileOptions)
    {
        ArgumentNullException.ThrowIfNull(composedSource);
        ArgumentNullException.ThrowIfNull(sourceName);
        ArgumentNullException.ThrowIfNull(compileOptions);
        var options = compileOptions.ToArray();
        using var hash = IncrementalHash.CreateHash(HashAlgorithmName.SHA256);
        Append(hash, composedSource);
        Append(hash, sourceName);
        Append(hash, options.Length.ToString(System.Globalization.CultureInfo.InvariantCulture));
        foreach (var option in options)
            Append(hash, option);
        return Convert.ToHexString(hash.GetHashAndReset());
    }

    /// <summary>Gets the key of a consumer source compiled after the device source of the domain options, with the options of the device module compile.</summary>
    internal static string Key(string consumerSource, string sourceName, MathBlockDomainOptions domainOptions, IEnumerable<string> compileOptions) =>
        Key(MathBlockCudaDeviceModule.ComposeSource(consumerSource, domainOptions), sourceName, compileOptions);

    /// <summary>Gets the key fields for the NVRTC options that <c>MathBlocksCudaNative.CompilePtx</c> passes for the device of ordinal 0 (production setting, --fmad=false). Needs a device.</summary>
    internal static string[] DeviceCompileOptions()
    {
        var native = typeof(MathBlockCatalog).Assembly.GetType("Supprocom.MathBlocks.Cuda.MathBlocksCudaNative", throwOnError: true)!;
        _ = native.GetMethod("EnsureContext", BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.Static)!.Invoke(null, [0]);
        var architecture = (string)native.GetMethod("ResolvePtxArchitecture", BindingFlags.NonPublic | BindingFlags.Static)!.Invoke(null, [0])!;
        return [$"architecture={architecture}", "--fmad=false", "--prec-div=true", "--prec-sqrt=true"];
    }

    /// <summary>Gets the loaded module and function for a key, loading it with <paramref name="load"/> on first use.</summary>
    internal (IntPtr Module, IntPtr Function) GetOrLoad(string key, Func<(IntPtr Module, IntPtr Function)> load)
    {
        ArgumentException.ThrowIfNullOrEmpty(key);
        ArgumentNullException.ThrowIfNull(load);
        lock (gate)
        {
            ObjectDisposedException.ThrowIf(disposed, this);
            if (entries.TryGetValue(key, out var entry))
                return entry;
            entry = load();
            entries[key] = entry;
            return entry;
        }
    }

    /// <inheritdoc />
    public void Dispose()
    {
        (IntPtr Module, IntPtr Function)[] loaded;
        lock (gate)
        {
            if (disposed)
                return;
            disposed = true;
            loaded = [.. entries.Values];
            entries.Clear();
        }

        foreach (var (module, _) in loaded)
            unload(module);
    }

    private static void Append(IncrementalHash hash, string text)
    {
        var bytes = Encoding.UTF8.GetBytes(text);
        hash.AppendData(BitConverter.GetBytes(bytes.Length));
        hash.AppendData(bytes);
    }
}
