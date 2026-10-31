using System.Diagnostics;
using System.Globalization;

namespace Supprocom.MathBlocks;

/// <summary>Describes one Formula Interchange profile.</summary>
[DebuggerDisplay("Formula profile {ProfileVersion}, {Operations.Count} operations")]
public sealed class MathBlockFormulaProfileDescriptor
{
    private const string PublishedBase =
        "https://raw.githubusercontent.com/Supprocom/MathBlocks/main/formula/v";

    private readonly Dictionary<MathBlockOperation, MathBlockFormulaOperationMapping> byOperation;
    private readonly Dictionary<MathBlockFormulaSymbol, MathBlockOperation> bySymbol;

    internal MathBlockFormulaProfileDescriptor(
        MathBlockOpenMathProfileDescriptor openMathProfile,
        IReadOnlyList<MathBlockFormulaOperationMapping> operations,
        IReadOnlyList<MathBlockFormulaProfileArtifact> artifacts,
        string fingerprint)
    {
        var suffix = openMathProfile.ProfileVersion;
        OpenMathProfile = openMathProfile;
        OpenMathVersion = MathBlockFormulaInterchange.OpenMathVersion;
        ContentMathMlVersion = MathBlockFormulaInterchange.ContentMathMlVersion;
        ProfileVersion = suffix;
        ContentDictionaryBase = PublishedContentDictionaryBase(openMathProfile.Version);
        ContentDictionaryGroup = string.Concat(
            ContentDictionaryBase,
            "/mathblocks_formula_profile",
            suffix,
            ".cdg");
        OpenMathMediaType = MathBlockFormulaInterchange.OpenMathMediaType;
        ContentMathMlMediaType = MathBlockFormulaInterchange.ContentMathMlMediaType;
        ExactAnnotationMediaType = string.Concat(
            "application/vnd.supprocom.mathblocks.openmath-profile",
            suffix,
            "+xml");
        FormulaDictionary = string.Concat("mathblocks_formula", suffix);
        FormulaOperationDictionary = OperationDictionaryName(openMathProfile.Version);
        FormulaValueDictionary = string.Concat("mathblocks_formula_values", suffix);
        AnnotationSymbol = string.Concat("profile", suffix);
        Operations = Array.AsReadOnly(MathBlockCollectionPrimitives.Copy(operations));
        Artifacts = Array.AsReadOnly(MathBlockCollectionPrimitives.Copy(artifacts));
        Fingerprint = fingerprint;

        byOperation = new Dictionary<MathBlockOperation, MathBlockFormulaOperationMapping>(
            operations.Count,
            ReferenceEqualityComparer.Instance);
        bySymbol = new Dictionary<MathBlockFormulaSymbol, MathBlockOperation>(operations.Count);
        for (var index = 0; index < operations.Count; index++)
        {
            var mapping = operations[index];
            byOperation.Add(mapping.Operation, mapping);
            if (!bySymbol.TryAdd(mapping.Symbol, mapping.Operation))
            {
                throw new InvalidOperationException(
                    "The formula profile contains a duplicate operation symbol.");
            }
        }
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

    /// <summary>Gets the media type of the exact embedded OpenMath annotation.</summary>
    public string ExactAnnotationMediaType { get; }

    /// <summary>Gets the OpenMath profile of the exact embedded annotation.</summary>
    public MathBlockOpenMathProfileDescriptor OpenMathProfile { get; }

    /// <summary>Gets all mappings in standard-catalog order.</summary>
    public IReadOnlyList<MathBlockFormulaOperationMapping> Operations { get; }

    /// <summary>Gets all embedded artifacts of this profile.</summary>
    public IReadOnlyList<MathBlockFormulaProfileArtifact> Artifacts { get; }

    /// <summary>Gets the SHA-256 fingerprint of the ordered mapping contract.</summary>
    public string Fingerprint { get; }

    internal string FormulaDictionary { get; }

    internal string FormulaOperationDictionary { get; }

    internal string FormulaValueDictionary { get; }

    internal string AnnotationSymbol { get; }

    /// <summary>Gets a value that indicates whether this profile maps an exact operation instance.</summary>
    public bool Contains(MathBlockOperation? operation) =>
        operation is not null && byOperation.ContainsKey(operation);

    /// <summary>Gets this profile's mapping for an exact operation instance.</summary>
    public bool TryGetOperationMapping(
        MathBlockOperation? operation,
        out MathBlockFormulaOperationMapping? mapping)
    {
        mapping = null;
        if (operation is null || !byOperation.TryGetValue(operation, out var found))
            return false;
        mapping = found;
        return true;
    }

    /// <summary>Gets the exact operation for one of this profile's symbols.</summary>
    public bool TryGetOperation(
        MathBlockFormulaSymbol symbol,
        out MathBlockOperation? operation)
    {
        operation = null;
        if (!bySymbol.TryGetValue(symbol, out var found))
            return false;
        operation = found;
        return true;
    }

    internal bool IsMathBlocksDictionary(string dictionary) =>
        string.Equals(dictionary, FormulaOperationDictionary, StringComparison.Ordinal) ||
        string.Equals(dictionary, FormulaValueDictionary, StringComparison.Ordinal) ||
        string.Equals(dictionary, FormulaDictionary, StringComparison.Ordinal);

    internal static string PublishedContentDictionaryBase(int version) =>
        string.Concat(PublishedBase, version.ToString(CultureInfo.InvariantCulture));

    internal static string OperationDictionaryName(int version) =>
        string.Concat(
            "mathblocks_formula_operations",
            version.ToString(CultureInfo.InvariantCulture));
}
