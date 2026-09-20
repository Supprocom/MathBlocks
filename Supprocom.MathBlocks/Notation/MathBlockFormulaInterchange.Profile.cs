using System.Diagnostics;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;

namespace Supprocom.MathBlocks;

/// <summary>Identifies one formula-interchange XML vocabulary.</summary>
public enum MathBlockFormulaFormat
{
    /// <summary>OpenMath 2.0 Revision 2 XML.</summary>
    OpenMath = 1,

    /// <summary>Strict Content MathML 3.0 XML.</summary>
    ContentMathMl = 2
}

/// <summary>Identifies how a MathBlocks operation is represented in a formula.</summary>
public enum MathBlockFormulaMappingKind
{
    /// <summary>The operation uses an established OpenMath content-dictionary symbol.</summary>
    OfficialContentDictionary = 1,

    /// <summary>The operation uses an exact symbol from the versioned MathBlocks dictionary.</summary>
    MathBlocksExtension = 2
}

/// <summary>Classifies how one operation is expressed by a formula vocabulary.</summary>
public enum MathBlockFormulaMappingClassification
{
    /// <summary>The operation maps to one content-dictionary symbol application.</summary>
    DirectMapping = 1,

    /// <summary>The operation maps to a fixed, normative expression pattern.</summary>
    CanonicalPatternMapping = 2,

    /// <summary>The operation cannot be represented by the vocabulary.</summary>
    Unsupported = 3
}

/// <summary>Identifies one OpenMath content-dictionary symbol.</summary>
[DebuggerDisplay("{Dictionary}:{Name}")]
public readonly record struct MathBlockFormulaSymbol(
    string ContentDictionaryBase,
    string Dictionary,
    string Name);

/// <summary>Describes the total formula mapping for one standard operation.</summary>
[DebuggerDisplay("{Operation.Identity}: {Symbol.Dictionary}:{Symbol.Name}")]
public sealed class MathBlockFormulaOperationMapping
{
    internal MathBlockFormulaOperationMapping(
        MathBlockOperation operation,
        MathBlockFormulaMappingClassification classification,
        MathBlockFormulaMappingKind kind,
        MathBlockFormulaSymbol symbol)
    {
        Operation = operation;
        Classification = classification;
        Kind = kind;
        Symbol = symbol;
    }

    /// <summary>Gets the exact standard operation instance.</summary>
    public MathBlockOperation Operation { get; }

    /// <summary>Gets the immutable operation identity.</summary>
    public string Identity => Operation.Identity;

    /// <summary>Gets the operation arity.</summary>
    public int Arity => Operation.Arity;

    /// <summary>Gets the mapping classification.</summary>
    public MathBlockFormulaMappingClassification Classification { get; }

    /// <summary>Gets the symbol provenance.</summary>
    public MathBlockFormulaMappingKind Kind { get; }

    /// <summary>Gets the symbol used by every supported formula vocabulary.</summary>
    public MathBlockFormulaSymbol Symbol { get; }
}

/// <summary>Describes one embedded Formula Interchange Profile 1 artifact.</summary>
[DebuggerDisplay("{PackagePath}, {Length} bytes")]
public sealed class MathBlockFormulaProfileArtifact
{
    private readonly byte[] content;

    internal MathBlockFormulaProfileArtifact(
        string name,
        int length,
        string sha256,
        bool isNormative,
        byte[] content)
    {
        Name = name;
        PackagePath = string.Concat("formula/v1/", name);
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

public static partial class MathBlockFormulaInterchange
{
    /// <summary>Gets the supported OpenMath standard version.</summary>
    public const string OpenMathVersion = "2.0";

    /// <summary>Gets the normative Content MathML version.</summary>
    public const string ContentMathMlVersion = "3.0";

    /// <summary>Gets the formula-interchange profile version.</summary>
    public const string ProfileVersion = "1";

    /// <summary>Gets the OpenMath XML media type.</summary>
    public const string OpenMathMediaType = "application/openmath+xml";

    /// <summary>Gets the Content MathML XML media type.</summary>
    public const string ContentMathMlMediaType = "application/mathml-content+xml";

    /// <summary>Gets the media type of the exact embedded Profile 1 annotation.</summary>
    public const string ExactAnnotationMediaType =
        "application/vnd.supprocom.mathblocks.openmath-profile1+xml";

    /// <summary>Gets the official OpenMath content-dictionary base URI.</summary>
    public const string OfficialContentDictionaryBase = "http://www.openmath.org/cd";

    /// <summary>Gets the fixed formula-interchange content-dictionary base URI.</summary>
    public const string ContentDictionaryBase =
        "https://raw.githubusercontent.com/Supprocom/MathBlocks/main/formula/v1";

    /// <summary>Gets the fixed formula-interchange content-dictionary-group URI.</summary>
    public const string ContentDictionaryGroup =
        ContentDictionaryBase + "/mathblocks_formula_profile1.cdg";

    internal const string FormulaDictionary = "mathblocks_formula1";
    internal const string FormulaOperationDictionary = "mathblocks_formula_operations1";
    internal const string FormulaValueDictionary = "mathblocks_formula_values1";
    private static readonly Lazy<FormulaProfileState> FormulaProfile =
        new(CreateFormulaProfile);
    private const string FormulaResourcePrefix = "Supprocom.MathBlocks.Formula.v1.";

    /// <summary>Gets the immutable, total Formula Interchange Profile 1 descriptor.</summary>
    public static MathBlockFormulaProfileDescriptor Profile =>
        FormulaProfile.Value.Descriptor;

    /// <summary>Gets the total formula mapping for an exact standard operation instance.</summary>
    public static bool TryGetOperationMapping(
        MathBlockOperation? operation,
        out MathBlockFormulaOperationMapping? mapping)
    {
        mapping = null;
        return operation is not null &&
               FormulaProfile.Value.ByOperation.TryGetValue(operation, out mapping);
    }

    /// <summary>Gets the exact standard operation for a formula symbol.</summary>
    public static bool TryGetOperation(
        MathBlockFormulaSymbol symbol,
        out MathBlockOperation? operation) =>
        FormulaProfile.Value.BySymbol.TryGetValue(symbol, out operation);

    internal static MathBlockFormulaOperationMapping RequireMapping(
        MathBlockOperation? operation)
    {
        if (operation is not null &&
            FormulaProfile.Value.ByOperation.TryGetValue(operation, out var mapping))
        {
            return mapping;
        }
        throw new InvalidOperationException(
            "The formula contains an operation outside the standard catalog.");
    }

    private static FormulaProfileState CreateFormulaProfile()
    {
        var catalog = MathBlockCatalog.Standard.Operations;
        var mappings = new MathBlockFormulaOperationMapping[catalog.Count];
        var byOperation = new Dictionary<MathBlockOperation, MathBlockFormulaOperationMapping>(
            ReferenceEqualityComparer.Instance);
        var bySymbol = new Dictionary<MathBlockFormulaSymbol, MathBlockOperation>();
        var fingerprintSource = new StringBuilder();
        fingerprintSource.Append("mathblocks-formula-profile-1\n");

        for (var index = 0; index < catalog.Count; index++)
        {
            var operation = catalog[index];
            var symbol = CreateOperationSymbol(operation, out var kind);
            var mapping = new MathBlockFormulaOperationMapping(
                operation,
                MathBlockFormulaMappingClassification.DirectMapping,
                kind,
                symbol);
            mappings[index] = mapping;
            byOperation.Add(operation, mapping);
            if (!bySymbol.TryAdd(symbol, operation))
            {
                throw new InvalidOperationException(
                    "The formula profile contains a duplicate operation symbol.");
            }

            fingerprintSource
                .Append(operation.Identity).Append('|')
                .Append((int)mapping.Classification).Append('|')
                .Append((int)kind).Append('|')
                .Append(symbol.ContentDictionaryBase).Append('|')
                .Append(symbol.Dictionary).Append('|')
                .Append(symbol.Name).Append('\n');
        }

        if (mappings.Length != 337)
        {
            throw new InvalidOperationException(
                "Formula Interchange Profile 1 requires exactly 337 operations.");
        }

        var fingerprint = Convert.ToHexString(
            SHA256.HashData(Encoding.UTF8.GetBytes(fingerprintSource.ToString())));
        FormulaArtifactAuthority[] authority =
        [
            new("mathblocks_formula1.ocd", 867, "17A14DB6B311C2E9FEC5FFAB8C6B1AA79DC670880946A1EAAB62EB5DDE1E780B", true),
            new("mathblocks_formula_mappings1.xml", 88249, "3694DD971BBB0953D5826286CE8B52BC359367EAF8F7338089B159A7DD5ECDED", true),
            new("mathblocks_formula_mappings1.rnc", 807, "44FAFAD207FF04CADC90A240965F6FFAB1932FA67AAA106095ECA3A94663C96D", true),
            new("mathblocks_formula_mathml1.rnc", 968, "10F0A5D854EF32265D8DE103F38B0FF3B9943D02D656D7133A38A1AE274591AC", true),
            new("mathblocks_formula_openmath1.rnc", 1325, "8B8C176E4F71C1DB8B592841F7C9072E33FF064C89133A029CA0134D29128C6B", true),
            new("mathblocks_formula_operations1.ocd", 85903, "DCF91AE2200F69A8FEB88D33724DAEB3AB2A42F68698F9ABB99B771CE72916F6", true),
            new("mathblocks_formula_profile1.cdg", 2144, "D9AC30323EEEAD7252EE3AFE91444A11A6B8C43AE7F38AE515600F999F070824", true),
            new("mathblocks_formula_values1.ocd", 2891, "FE73F951A443B3B2694D3C56C25D34B23F2F80D11DEE2FCC88A5B72D70E059CB", true),
            new("README.md", 4288, "1D9815FDA4765250000526099F5F03C82448961C594FACBBBD76BCC2AB23DA20", false)
        ];
        var artifacts = new MathBlockFormulaProfileArtifact[authority.Length];
        var assembly = typeof(MathBlockFormulaInterchange).Assembly;
        for (var index = 0; index < authority.Length; index++)
            artifacts[index] = CreateArtifact(assembly, authority[index]);

        return new FormulaProfileState(
            new MathBlockFormulaProfileDescriptor(mappings, artifacts, fingerprint),
            byOperation,
            bySymbol);
    }

    private static MathBlockFormulaProfileArtifact CreateArtifact(
        Assembly assembly,
        FormulaArtifactAuthority authority)
    {
        using var stream = assembly.GetManifestResourceStream(
            string.Concat(FormulaResourcePrefix, authority.Name)) ??
            throw new InvalidOperationException("An embedded formula profile artifact is missing.");
        var content = new byte[authority.Length];
        stream.ReadExactly(content);
        if (stream.ReadByte() != -1 ||
            Convert.ToHexString(SHA256.HashData(content)) != authority.Sha256)
        {
            throw new InvalidOperationException("An embedded formula profile artifact is invalid.");
        }
        return new MathBlockFormulaProfileArtifact(
            authority.Name,
            authority.Length,
            authority.Sha256,
            authority.IsNormative,
            content);
    }

    private static MathBlockFormulaSymbol CreateOperationSymbol(
        MathBlockOperation operation,
        out MathBlockFormulaMappingKind kind)
    {
        var official = operation.Identifier switch
        {
            "boolean.and" => ("logic1", "and"),
            "boolean.not" => ("logic1", "not"),
            "boolean.or" => ("logic1", "or"),
            "boolean.xor" => ("logic1", "xor"),
            "complex.conjugate" => ("complex1", "conjugate"),
            "complex.create" => ("complex1", "complex_cartesian"),
            "complex.from-polar" => ("complex1", "complex_polar"),
            "complex.phase" => ("complex1", "argument"),
            "scalar.absolute" => ("arith1", "abs"),
            "scalar.add" => ("arith1", "plus"),
            "scalar.arc-cosine" => ("transc1", "arccos"),
            "scalar.arc-sine" => ("transc1", "arcsin"),
            "scalar.arc-tangent" => ("transc1", "arctan"),
            "scalar.ceiling" => ("rounding1", "ceiling"),
            "scalar.cosine" => ("transc1", "cos"),
            "scalar.divide" => ("arith1", "divide"),
            "scalar.equal" => ("relation1", "eq"),
            "scalar.exponential" => ("transc1", "exp"),
            "scalar.floor" => ("rounding1", "floor"),
            "scalar.greater-or-equal" => ("relation1", "geq"),
            "scalar.greater-than" => ("relation1", "gt"),
            "scalar.hyperbolic-cosine" => ("transc1", "cosh"),
            "scalar.hyperbolic-sine" => ("transc1", "sinh"),
            "scalar.hyperbolic-tangent" => ("transc1", "tanh"),
            "scalar.inverse-hyperbolic-cosine" => ("transc1", "arccosh"),
            "scalar.inverse-hyperbolic-sine" => ("transc1", "arcsinh"),
            "scalar.inverse-hyperbolic-tangent" => ("transc1", "arctanh"),
            "scalar.less-or-equal" => ("relation1", "leq"),
            "scalar.less-than" => ("relation1", "lt"),
            "scalar.multiply" => ("arith1", "times"),
            "scalar.natural-logarithm" => ("transc1", "ln"),
            "scalar.negate" => ("arith1", "unary_minus"),
            "scalar.not-equal" => ("relation1", "neq"),
            "scalar.power" => ("arith1", "power"),
            "scalar.sine" => ("transc1", "sin"),
            "scalar.subtract" => ("arith1", "minus"),
            "scalar.tangent" => ("transc1", "tan"),
            "scalar.truncate" => ("rounding1", "trunc"),
            _ => default
        };

        if (official != default)
        {
            kind = MathBlockFormulaMappingKind.OfficialContentDictionary;
            return new MathBlockFormulaSymbol(
                OfficialContentDictionaryBase,
                official.Item1,
                official.Item2);
        }

        kind = MathBlockFormulaMappingKind.MathBlocksExtension;
        return new MathBlockFormulaSymbol(
            ContentDictionaryBase,
            FormulaOperationDictionary,
            OperationSymbolName(operation.Identity));
    }

    private static string OperationSymbolName(string identity)
    {
        var separator = identity.LastIndexOf('@');
        if (separator <= 0 || separator == identity.Length - 1)
            throw new InvalidOperationException("A standard operation identity is invalid.");
        return string.Concat("op.", identity[..separator], ".v", identity[(separator + 1)..]);
    }

    private sealed record FormulaProfileState(
        MathBlockFormulaProfileDescriptor Descriptor,
        IReadOnlyDictionary<MathBlockOperation, MathBlockFormulaOperationMapping> ByOperation,
        IReadOnlyDictionary<MathBlockFormulaSymbol, MathBlockOperation> BySymbol);

    private readonly record struct FormulaArtifactAuthority(
        string Name,
        int Length,
        string Sha256,
        bool IsNormative);
}
