using System.Diagnostics;
using System.Globalization;

namespace Supprocom.MathBlocks;

/// <summary>Describes one immutable MathBlocks OpenMath profile.</summary>
[DebuggerDisplay("Profile {ProfileVersion}, {Operations.Count} operations")]
public sealed class MathBlockOpenMathProfileDescriptor
{
    private const string PublishedBase =
        "https://raw.githubusercontent.com/Supprocom/MathBlocks/main/openmath/v";

    private readonly Dictionary<MathBlockOperation, MathBlockOpenMathOperationSymbol> symbolsByOperation;
    private readonly Dictionary<string, MathBlockOperation> operationsBySymbol;

    internal MathBlockOpenMathProfileDescriptor(
        int version,
        MathBlockRegistry registry,
        IReadOnlyList<MathBlockOperation> operations,
        IReadOnlyList<MathBlockOpenMathProfileArtifact> artifacts)
    {
        var suffix = version.ToString(CultureInfo.InvariantCulture);
        Version = version;
        Registry = registry;
        ProgramDictionary = string.Concat("mathblocks_program", suffix);
        OperationDictionary = string.Concat("mathblocks_operations", suffix);
        TypeDictionary = string.Concat("mathblocks_types", suffix);
        ValueDictionary = string.Concat("mathblocks_values", suffix);
        StandardVersion = MathBlockOpenMath.StandardVersion;
        ProfileVersion = suffix;
        MediaType = MathBlockOpenMath.MediaType;
        CanonicalizationAlgorithm = MathBlockOpenMath.CanonicalizationAlgorithm;
        ContentDictionaryBase = string.Concat(PublishedBase, suffix);
        ContentDictionaryGroup = string.Concat(
            ContentDictionaryBase,
            "/mathblocks_profile",
            suffix,
            ".cdg");

        var definitions = new MathBlockOpenMathOperationDefinition[operations.Count];
        symbolsByOperation = new Dictionary<MathBlockOperation, MathBlockOpenMathOperationSymbol>(
            operations.Count,
            ReferenceEqualityComparer.Instance);
        operationsBySymbol = new Dictionary<string, MathBlockOperation>(
            operations.Count,
            StringComparer.Ordinal);
        for (var index = 0; index < operations.Count; index++)
        {
            var operation = operations[index];
            var symbol = new MathBlockOpenMathOperationSymbol(
                OperationDictionary,
                MathBlockOpenMath.OperationSymbolName(operation.Identity));
            if (!operationsBySymbol.TryAdd(symbol.Name, operation))
            {
                throw new InvalidOperationException(
                    "The OpenMath profile has duplicate operation symbols.");
            }
            symbolsByOperation.Add(operation, symbol);
            definitions[index] = new MathBlockOpenMathOperationDefinition(operation, symbol);
        }
        Operations = Array.AsReadOnly(definitions);
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

    /// <summary>Gets all embedded artifacts of this profile.</summary>
    public IReadOnlyList<MathBlockOpenMathProfileArtifact> Artifacts { get; }

    internal int Version { get; }

    internal MathBlockRegistry Registry { get; }

    internal string ProgramDictionary { get; }

    internal string OperationDictionary { get; }

    internal string TypeDictionary { get; }

    internal string ValueDictionary { get; }

    internal Dictionary<string, MathBlockOperation> OperationSymbols => operationsBySymbol;

    /// <summary>Gets a value that indicates whether this profile contains an exact operation instance.</summary>
    public bool Contains(MathBlockOperation? operation) =>
        operation is not null && symbolsByOperation.ContainsKey(operation);

    /// <summary>Gets this profile's symbol for an exact operation instance.</summary>
    public bool TryGetOperationSymbol(
        MathBlockOperation? operation,
        out MathBlockOpenMathOperationSymbol symbol)
    {
        if (operation is not null && symbolsByOperation.TryGetValue(operation, out symbol))
            return true;
        symbol = default;
        return false;
    }

    /// <summary>Gets the exact operation for one of this profile's symbols.</summary>
    public bool TryGetOperation(
        MathBlockOpenMathOperationSymbol symbol,
        out MathBlockOperation? operation)
    {
        operation = null;
        if (!string.Equals(symbol.Dictionary, OperationDictionary, StringComparison.Ordinal) ||
            string.IsNullOrEmpty(symbol.Name) ||
            !operationsBySymbol.TryGetValue(symbol.Name, out var found))
        {
            return false;
        }
        operation = found;
        return true;
    }
}
