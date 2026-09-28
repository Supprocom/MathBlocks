using System.Diagnostics;

namespace Supprocom.MathBlocks;

/// <summary>Describes the immutable MathBlocks OpenMath Profile 1.</summary>
[DebuggerDisplay("Profile {ProfileVersion}, {Operations.Count} operations")]
public sealed class MathBlockOpenMathProfileDescriptor
{
    internal MathBlockOpenMathProfileDescriptor(
        IReadOnlyList<MathBlockOpenMathOperationDefinition> operations,
        IReadOnlyList<MathBlockOpenMathProfileArtifact> artifacts)
    {
        StandardVersion = MathBlockOpenMath.StandardVersion;
        ProfileVersion = MathBlockOpenMath.ProfileVersion;
        MediaType = MathBlockOpenMath.MediaType;
        CanonicalizationAlgorithm = MathBlockOpenMath.CanonicalizationAlgorithm;
        ContentDictionaryBase = MathBlockOpenMath.ContentDictionaryBase;
        ContentDictionaryGroup = MathBlockOpenMath.ContentDictionaryGroup;
        Operations = Array.AsReadOnly(MathBlockCollectionPrimitives.Copy(operations));
        Artifacts = Array.AsReadOnly(MathBlockCollectionPrimitives.Copy(artifacts));
    }

    /// <summary>Gets the OpenMath standard version.</summary>
    public string StandardVersion { get; }

    /// <summary>Gets the MathBlocks profile version.</summary>
    public string ProfileVersion { get; }

    /// <summary>Gets the OpenMath XML media type.</summary>
    public string MediaType { get; }

    /// <summary>Gets the canonicalization algorithm URI.</summary>
    public string CanonicalizationAlgorithm { get; }

    /// <summary>Gets the fixed content dictionary base URI.</summary>
    public string ContentDictionaryBase { get; }

    /// <summary>Gets the fixed content dictionary group URI.</summary>
    public string ContentDictionaryGroup { get; }

    /// <summary>Gets operation definitions in standard catalog order.</summary>
    public IReadOnlyList<MathBlockOpenMathOperationDefinition> Operations { get; }

    /// <summary>Gets all embedded Profile 1 artifacts.</summary>
    public IReadOnlyList<MathBlockOpenMathProfileArtifact> Artifacts { get; }
}
