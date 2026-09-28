using System.Diagnostics;

namespace Supprocom.MathBlocks;

/// <summary>Describes Formula Interchange Profile 1.</summary>
[DebuggerDisplay("Formula profile {ProfileVersion}, {Operations.Count} operations")]
public sealed class MathBlockFormulaProfileDescriptor
{
    internal MathBlockFormulaProfileDescriptor(
        IReadOnlyList<MathBlockFormulaOperationMapping> operations,
        IReadOnlyList<MathBlockFormulaProfileArtifact> artifacts,
        string fingerprint)
    {
        OpenMathVersion = MathBlockFormulaInterchange.OpenMathVersion;
        ContentMathMlVersion = MathBlockFormulaInterchange.ContentMathMlVersion;
        ProfileVersion = MathBlockFormulaInterchange.ProfileVersion;
        ContentDictionaryBase = MathBlockFormulaInterchange.ContentDictionaryBase;
        ContentDictionaryGroup = MathBlockFormulaInterchange.ContentDictionaryGroup;
        OpenMathMediaType = MathBlockFormulaInterchange.OpenMathMediaType;
        ContentMathMlMediaType = MathBlockFormulaInterchange.ContentMathMlMediaType;
        Operations = Array.AsReadOnly(MathBlockCollectionPrimitives.Copy(operations));
        Artifacts = Array.AsReadOnly(MathBlockCollectionPrimitives.Copy(artifacts));
        Fingerprint = fingerprint;
    }

    /// <summary>Gets the supported OpenMath standard version.</summary>
    public string OpenMathVersion { get; }

    /// <summary>Gets the normative Content MathML version.</summary>
    public string ContentMathMlVersion { get; }

    /// <summary>Gets the MathBlocks formula profile version.</summary>
    public string ProfileVersion { get; }

    /// <summary>Gets the fixed MathBlocks formula dictionary base URI.</summary>
    public string ContentDictionaryBase { get; }

    /// <summary>Gets the fixed MathBlocks formula dictionary-group URI.</summary>
    public string ContentDictionaryGroup { get; }

    /// <summary>Gets the OpenMath media type.</summary>
    public string OpenMathMediaType { get; }

    /// <summary>Gets the Content MathML media type.</summary>
    public string ContentMathMlMediaType { get; }

    /// <summary>Gets all 337 mappings in standard-catalog order.</summary>
    public IReadOnlyList<MathBlockFormulaOperationMapping> Operations { get; }

    /// <summary>Gets all embedded Formula Interchange Profile 1 artifacts.</summary>
    public IReadOnlyList<MathBlockFormulaProfileArtifact> Artifacts { get; }

    /// <summary>Gets the SHA-256 fingerprint of the ordered mapping contract.</summary>
    public string Fingerprint { get; }
}
