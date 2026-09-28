using System.Diagnostics;

namespace Supprocom.MathBlocks;

/// <summary>Describes one embedded Profile 1 artifact.</summary>
[DebuggerDisplay("{PackagePath}, {Length} bytes")]
public sealed class MathBlockOpenMathProfileArtifact
{
    private readonly byte[] content;

    internal MathBlockOpenMathProfileArtifact(
        string name,
        int length,
        string sha256,
        bool isNormative,
        byte[] content)
    {
        Name = name;
        PackagePath = string.Concat("openmath/v1/", name);
        Length = length;
        Sha256 = sha256;
        IsNormative = isNormative;
        this.content = content;
    }

    /// <summary>Gets the artifact file name.</summary>
    public string Name { get; }

    /// <summary>Gets the package-relative artifact path.</summary>
    public string PackagePath { get; }

    /// <summary>Gets the exact byte length.</summary>
    public int Length { get; }

    /// <summary>Gets the uppercase SHA-256 value.</summary>
    public string Sha256 { get; }

    /// <summary>Gets a value that identifies a normative artifact.</summary>
    public bool IsNormative { get; }

    /// <summary>Opens a new read-only stream for the exact artifact bytes.</summary>
    public Stream OpenRead() => new MemoryStream(content, 0, content.Length, false, false);
}
