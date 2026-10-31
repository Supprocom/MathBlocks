using System.Reflection;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Checks how MathBlocks finds an installed NVRTC, without loading NVRTC or using a device.</summary>
public sealed class MathBlockNvrtcLoaderTests
{
    private static readonly Type LoaderType = typeof(MathBlockCatalog).Assembly.GetType(
        "Supprocom.MathBlocks.Cuda.MathBlocksNvrtcLoader",
        throwOnError: true)!;

    /// <summary>Verifies the Linux names are probed newest major first, then the development link.</summary>
    [Fact]
    public void LinuxNamesAreProbedNewestMajorFirst()
    {
        Assert.Equal(
            ["libnvrtc.so.13", "libnvrtc.so.12", "libnvrtc.so"],
            GetField<string[]>("LinuxNames"));
        Assert.Equal(12, GetField<int>("MinimumMajor"));
        Assert.Equal(0, GetField<int>("MinimumMinor"));
    }

    /// <summary>Verifies Windows probes CUDA_PATH before PATH and the newest major first in each directory.</summary>
    [Fact]
    public void WindowsCandidatesFollowCudaPathThenPathNewestMajorFirst()
    {
        var candidates = Invoke<string[]>(
            "CreateWindowsCandidates",
            @"C:\Program Files\NVIDIA\CUDA\v12.8\",
            @"C:\Tools;relative\bin;.;""D:\Quoted Dir"";c:\program files\nvidia\cuda\v12.8\bin;\\server\share\cuda;;");

        var toolkit = @"C:\Program Files\NVIDIA\CUDA\v12.8";
        Assert.Equal(
            [
                toolkit + @"\bin\nvrtc64_130_0.dll",
                toolkit + @"\bin\nvrtc64_120_0.dll",
                toolkit + @"\bin\x64\nvrtc64_130_0.dll",
                toolkit + @"\bin\x64\nvrtc64_120_0.dll",
                @"C:\Tools\nvrtc64_130_0.dll",
                @"C:\Tools\nvrtc64_120_0.dll",
                @"D:\Quoted Dir\nvrtc64_130_0.dll",
                @"D:\Quoted Dir\nvrtc64_120_0.dll",
                @"\\server\share\cuda\nvrtc64_130_0.dll",
                @"\\server\share\cuda\nvrtc64_120_0.dll"
            ],
            candidates);
    }

    /// <summary>Verifies Windows probes only PATH when CUDA_PATH is unset or relative.</summary>
    [Fact]
    public void WindowsCandidatesSkipUnsetOrRelativeCudaPath()
    {
        Assert.Empty(Invoke<string[]>("CreateWindowsCandidates", null, null));
        Assert.Equal(
            [@"E:\cuda\bin\nvrtc64_130_0.dll", @"E:\cuda\bin\nvrtc64_120_0.dll"],
            Invoke<string[]>("CreateWindowsCandidates", @"cuda", "E:/cuda/bin/"));
    }

    /// <summary>Verifies a missing NVRTC fails with the requirement and every name searched.</summary>
    [Fact]
    public void MissingNvrtcNamesTheRequirementAndEverySearchedCandidate()
    {
        // A library that loads but has no nvrtcVersion export must be rejected, not used.
        var foreign = OperatingSystem.IsWindows() ? "kernel32.dll" : "libc.so.6";
        string[] candidates =
        [
            "libmathblocks-missing-nvrtc.so.13",
            Path.Combine(Path.GetTempPath(), "mathblocks-missing", "nvrtc64_130_0.dll"),
            foreign
        ];

        var exception = Assert.Throws<TargetInvocationException>(() =>
            LoaderType.GetMethod("Load", BindingFlags.NonPublic | BindingFlags.Static, [typeof(string[])])!
                .Invoke(null, [candidates]));
        var failure = Assert.IsType<InvalidOperationException>(exception.InnerException);

        Assert.Contains("requires an NVIDIA driver", failure.Message, StringComparison.Ordinal);
        Assert.Contains("NVIDIA CUDA Toolkit, version 12.0 or later", failure.Message, StringComparison.Ordinal);
        Assert.Contains("MathBlocks does not ship NVRTC", failure.Message, StringComparison.Ordinal);
        Assert.Contains(
            $"Searched, in order: {candidates[0]} (not loaded); {candidates[1]} (not loaded); {foreign} (no nvrtcVersion).",
            failure.Message,
            StringComparison.Ordinal);
    }

    private static T GetField<T>(string name) =>
        (T)LoaderType.GetField(name, BindingFlags.NonPublic | BindingFlags.Static)!.GetValue(null)!;

    private static T Invoke<T>(string name, params object?[] arguments) =>
        (T)LoaderType.GetMethod(name, BindingFlags.NonPublic | BindingFlags.Static)!.Invoke(null, arguments)!;
}
