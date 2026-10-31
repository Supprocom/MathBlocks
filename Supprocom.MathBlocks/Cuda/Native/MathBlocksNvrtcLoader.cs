using System.Globalization;
using System.Runtime.InteropServices;
using System.Text;

namespace Supprocom.MathBlocks.Cuda;

// Finds NVRTC from an installed CUDA Toolkit. MathBlocks ships no NVRTC binary.
internal static class MathBlocksNvrtcLoader
{
    // CUDA 12 is the first toolkit whose NVRTC uses the major-only Linux soname and the
    // nvrtc64_<major>0_0.dll Windows name probed below. Every NVRTC entry point and option
    // MathBlocks uses exists in it.
    internal const int MinimumMajor = 12;
    internal const int MinimumMinor = 0;

    // Linux: names resolved by the system loader, newest supported major first. The
    // unversioned name is the toolkit's development link and is accepted only when the
    // library it opens reports at least the minimum version.
    internal static readonly string[] LinuxNames = ["libnvrtc.so.13", "libnvrtc.so.12", "libnvrtc.so"];

    // Windows: DLL names, newest supported major first, probed by full path in each directory.
    internal static readonly string[] WindowsNames = ["nvrtc64_130_0.dll", "nvrtc64_120_0.dll"];

    private static readonly Lock gate = new();
    private static LoadedNvrtc? current;

    public static MathBlockCudaNvrtcLibrary Library => Load().Library;

    public static bool TryGetHandle(out IntPtr handle)
    {
        lock (gate)
        {
            handle = current?.Handle ?? IntPtr.Zero;
            return current is not null;
        }
    }

    private static LoadedNvrtc Load()
    {
        lock (gate)
            return current ??= Load(CreateCandidates());
    }

    internal static string[] CreateCandidates() =>
        OperatingSystem.IsWindows()
            ? CreateWindowsCandidates(
                Environment.GetEnvironmentVariable("CUDA_PATH"),
                Environment.GetEnvironmentVariable("PATH"))
            : LinuxNames;

    // Directory order: %CUDA_PATH%\bin, %CUDA_PATH%\bin\x64, then each fully qualified PATH
    // entry in order. Within one directory the newest major comes first. Relative PATH
    // entries are skipped so the process working directory is never searched.
    internal static string[] CreateWindowsCandidates(string? cudaPath, string? path)
    {
        var directories = new List<string>();
        var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var toolkit = NormalizeWindowsDirectory(cudaPath);
        if (toolkit is not null)
        {
            Add(toolkit + "\\bin");
            Add(toolkit + "\\bin\\x64");
        }
        if (path is not null)
            foreach (var entry in path.Split(';'))
                if (NormalizeWindowsDirectory(entry) is { } directory)
                    Add(directory);

        var candidates = new string[directories.Count * WindowsNames.Length];
        for (var directory = 0; directory < directories.Count; directory++)
            for (var name = 0; name < WindowsNames.Length; name++)
                candidates[(directory * WindowsNames.Length) + name] = directories[directory] + "\\" + WindowsNames[name];
        return candidates;

        void Add(string directory)
        {
            if (seen.Add(directory))
                directories.Add(directory);
        }
    }

    private static string? NormalizeWindowsDirectory(string? value)
    {
        if (value is null)
            return null;
        var directory = value.Trim().Trim('"').Replace('/', '\\').TrimEnd('\\');
        var driveRooted = directory.Length >= 2 && char.IsAsciiLetter(directory[0]) && directory[1] == ':' &&
                          (directory.Length == 2 || directory[2] == '\\');
        var uncRooted = directory.StartsWith("\\\\", StringComparison.Ordinal) && directory.Length > 2;
        return driveRooted || uncRooted ? directory : null;
    }

    internal static LoadedNvrtc Load(string[] candidates)
    {
        var searched = new List<string>(candidates.Length);
        foreach (var candidate in candidates)
        {
            if (!NativeLibrary.TryLoad(candidate, out var handle))
            {
                searched.Add($"{candidate} (not loaded)");
                continue;
            }
            if (!TryGetVersion(handle, out var major, out var minor))
            {
                NativeLibrary.Free(handle);
                searched.Add($"{candidate} (no nvrtcVersion)");
                continue;
            }
            if (major < MinimumMajor || (major == MinimumMajor && minor < MinimumMinor))
            {
                NativeLibrary.Free(handle);
                searched.Add(string.Create(
                    CultureInfo.InvariantCulture,
                    $"{candidate} (NVRTC {major}.{minor}, below {MinimumMajor}.{MinimumMinor})"));
                continue;
            }

            var path = ResolvePath(handle, candidate);
            if (OperatingSystem.IsWindows())
                LoadWindowsBuiltins(path, major, minor);
            return new LoadedNvrtc(handle, new MathBlockCudaNvrtcLibrary(major, minor, path));
        }

        throw new InvalidOperationException(CreateMissingMessage(searched));
    }

    internal static string CreateMissingMessage(IReadOnlyList<string> searched)
    {
        var message = new StringBuilder()
            .Append("MathBlocks CUDA compilation requires an NVIDIA driver and the NVRTC library of an installed ")
            .Append("NVIDIA CUDA Toolkit, version ")
            .Append(MinimumMajor.ToString(CultureInfo.InvariantCulture))
            .Append('.')
            .Append(MinimumMinor.ToString(CultureInfo.InvariantCulture))
            .Append(" or later. MathBlocks does not ship NVRTC. ");
        message.Append(OperatingSystem.IsWindows()
            ? "Install the CUDA Toolkit, or put its bin directory in CUDA_PATH or PATH. "
            : "Install the CUDA Toolkit's NVRTC where the system library loader finds it. ");
        message.Append("Searched, in order: ").AppendJoin("; ", searched).Append('.');
        return message.ToString();
    }

    private static unsafe bool TryGetVersion(IntPtr handle, out int major, out int minor)
    {
        major = 0;
        minor = 0;
        if (!NativeLibrary.TryGetExport(handle, "nvrtcVersion", out var export))
            return false;
        int reportedMajor;
        int reportedMinor;
        var query = (delegate* unmanaged[Cdecl]<int*, int*, int>)export;
        if (query(&reportedMajor, &reportedMinor) != 0)
            return false;
        major = reportedMajor;
        minor = reportedMinor;
        return true;
    }

    // Windows candidates are full paths. On Linux the loader resolves the name, so the file is
    // the mapping in /proc/self/maps that contains the nvrtcVersion export.
    private static string ResolvePath(IntPtr handle, string candidate)
    {
        if (OperatingSystem.IsWindows() || !NativeLibrary.TryGetExport(handle, "nvrtcVersion", out var export))
            return candidate;
        try
        {
            var address = unchecked((ulong)export.ToInt64());
            foreach (var line in File.ReadLines("/proc/self/maps"))
            {
                var fields = line.Split(' ', 6, StringSplitOptions.RemoveEmptyEntries);
                if (fields.Length < 6)
                    continue;
                var range = fields[0].Split('-');
                if (range.Length == 2 &&
                    ulong.TryParse(range[0], NumberStyles.AllowHexSpecifier, CultureInfo.InvariantCulture, out var start) &&
                    ulong.TryParse(range[1], NumberStyles.AllowHexSpecifier, CultureInfo.InvariantCulture, out var end) &&
                    address >= start && address < end)
                {
                    return fields[5].Trim();
                }
            }
        }
        catch (IOException)
        {
        }
        return candidate;
    }

    // NVRTC needs the builtins DLL of its own toolkit. A later load of that DLL by module name
    // resolves to an already loaded module of the same name, so the copy beside the chosen NVRTC
    // is loaded first.
    private static void LoadWindowsBuiltins(string nvrtcPath, int major, int minor)
    {
        var directory = System.IO.Path.GetDirectoryName(nvrtcPath);
        if (string.IsNullOrEmpty(directory))
            return;
        var builtins = System.IO.Path.Join(
            directory,
            string.Create(CultureInfo.InvariantCulture, $"nvrtc-builtins64_{major}{minor}.dll"));
        if (File.Exists(builtins))
            _ = NativeLibrary.TryLoad(builtins, out _);
    }

    internal sealed class LoadedNvrtc(IntPtr handle, MathBlockCudaNvrtcLibrary library)
    {
        public IntPtr Handle { get; } = handle;

        public MathBlockCudaNvrtcLibrary Library { get; } = library;
    }
}
