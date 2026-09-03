namespace Supprocom.MathBlocks;

/// <summary>Specifies resource and metadata rules for an OpenMath import.</summary>
public sealed class MathBlockOpenMathImportOptions
{
    /// <summary>Gets the compatibility-preserving option set.</summary>
    public static MathBlockOpenMathImportOptions Default { get; } = new();

    /// <summary>Gets the maximum number of decoded document characters.</summary>
    public int MaximumDocumentCharacters { get; init; } =
        MathBlockOpenMath.MaximumDocumentCharacters;

    /// <summary>Gets the maximum number of source bytes.</summary>
    public int MaximumDocumentBytes { get; init; } =
        MathBlockOpenMath.MaximumDocumentUtf8Bytes;

    /// <summary>Gets the maximum number of program nodes.</summary>
    public int MaximumNodes { get; init; } = int.MaxValue;

    /// <summary>Gets the maximum number of program outputs.</summary>
    public int MaximumOutputs { get; init; } = int.MaxValue;

    /// <summary>Gets the maximum number of constant value elements.</summary>
    public int MaximumValueElements { get; init; } = int.MaxValue;

    /// <summary>Gets a value that requires canonical source notation.</summary>
    public bool RequireCanonicalSource { get; init; }

    /// <summary>Gets a value that enables source-location capture.</summary>
    public bool CaptureSourceLocations { get; init; }
}
