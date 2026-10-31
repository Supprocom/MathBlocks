using System.Globalization;

namespace Supprocom.MathBlocks.Cuda;

/// <summary>Describes the installed NVRTC library that compiles the CUDA device module in this process.</summary>
public sealed class MathBlockCudaNvrtcLibrary
{
    internal MathBlockCudaNvrtcLibrary(int major, int minor, string path)
    {
        Major = major;
        Minor = minor;
        Path = path;
    }

    /// <summary>
    /// Gets the NVRTC library that <see cref="MathBlockCudaDeviceModule.CompilePtx"/> uses, loading it on first access.
    /// </summary>
    /// <exception cref="InvalidOperationException">
    /// No installed NVRTC of a supported version was found; the message names the requirement and lists every
    /// name and path searched.
    /// </exception>
    public static MathBlockCudaNvrtcLibrary Current => MathBlocksNvrtcLoader.Library;

    /// <summary>Gets the NVRTC major version that <c>nvrtcVersion</c> reports.</summary>
    public int Major { get; }

    /// <summary>Gets the NVRTC minor version that <c>nvrtcVersion</c> reports.</summary>
    public int Minor { get; }

    /// <summary>Gets the file the NVRTC library was loaded from.</summary>
    public string Path { get; }

    /// <summary>Formats the NVRTC version and file for diagnostics.</summary>
    public override string ToString() =>
        string.Create(CultureInfo.InvariantCulture, $"NVRTC {Major}.{Minor} ({Path})");
}
