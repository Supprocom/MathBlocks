using System.Globalization;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;

namespace Supprocom.MathBlocks;

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

    private const string OutsideProfileKey = "MathBlocks.Formula.OutsideProfile";
    private static readonly Lazy<MathBlockFormulaProfileDescriptor> Profile1State =
        new(CreateProfile1);
    private static readonly Lazy<MathBlockFormulaProfileDescriptor> Profile2State =
        new(CreateProfile2);
    private static readonly Lazy<MathBlockFormulaProfileDescriptor>[] PublishedProfiles =
        [Profile1State, Profile2State];
    private static readonly Lazy<IReadOnlyList<MathBlockFormulaProfileDescriptor>> ProfileList =
        new(() => Array.AsReadOnly(new[] { Profile1State.Value, Profile2State.Value }));

    /// <summary>Gets the immutable, total Formula Interchange Profile 1 descriptor.</summary>
    public static MathBlockFormulaProfileDescriptor Profile => Profile1State.Value;

    /// <summary>Gets the immutable, total Formula Interchange Profile 2 descriptor.</summary>
    public static MathBlockFormulaProfileDescriptor Profile2 => Profile2State.Value;

    /// <summary>Gets every supported Formula Interchange profile in ascending version order.</summary>
    public static IReadOnlyList<MathBlockFormulaProfileDescriptor> Profiles => ProfileList.Value;

    /// <summary>Gets the total Profile 1 formula mapping for an exact standard operation instance.</summary>
    public static bool TryGetOperationMapping(
        MathBlockOperation? operation,
        out MathBlockFormulaOperationMapping? mapping) =>
        Profile.TryGetOperationMapping(operation, out mapping);

    /// <summary>Gets the exact standard operation for a Profile 1 formula symbol.</summary>
    public static bool TryGetOperation(
        MathBlockFormulaSymbol symbol,
        out MathBlockOperation? operation) =>
        Profile.TryGetOperation(symbol, out operation);

    // Creates a profile over every operation of an unpublished OpenMath profile, without
    // embedded artifacts. Only the published profiles are reachable through the public API.
    internal static MathBlockFormulaProfileDescriptor CreateUnpublishedProfile(
        MathBlockOpenMathProfileDescriptor openMathProfile)
    {
        ArgumentNullException.ThrowIfNull(openMathProfile);
        return CreateProfile(openMathProfile, []);
    }

    internal static Lazy<MathBlockFormulaProfileDescriptor>[] CreateCandidates(
        MathBlockFormulaProfileDescriptor[] profiles)
    {
        ArgumentNullException.ThrowIfNull(profiles);
        if (profiles.Length == 0)
            throw new ArgumentException("At least one formula profile is required.", nameof(profiles));
        var result = new Lazy<MathBlockFormulaProfileDescriptor>[profiles.Length];
        for (var index = 0; index < result.Length; index++)
        {
            var profile = profiles[index] ??
                throw new ArgumentException("A formula profile is null.", nameof(profiles));
            result[index] = new Lazy<MathBlockFormulaProfileDescriptor>(profile);
        }
        return result;
    }

    internal static MathBlockFormulaOperationMapping RequireMapping(
        MathBlockFormulaProfileDescriptor profile,
        MathBlockOperation? operation,
        bool highest)
    {
        if (profile.TryGetOperationMapping(operation, out var mapping))
            return mapping!;
        var target = string.Concat(
            "MathBlocks Formula Interchange Profile ",
            profile.ProfileVersion);
        var exception = new InvalidOperationException(operation is null
            ? string.Concat("The formula contains an operation outside ", target, ".")
            : string.Concat(
                "The formula contains operation '",
                operation.Identity,
                "', which is outside ",
                target,
                highest ? ", the highest supported profile." : "."));
        exception.Data[OutsideProfileKey] = profile.ProfileVersion;
        throw exception;
    }

    private static MathBlockFormulaProfileDescriptor CreateProfile1()
    {
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
        var profile = CreateProfile(MathBlockOpenMath.Profile, CreateArtifacts(1, authority));
        if (profile.Operations.Count != 337)
        {
            throw new InvalidOperationException(
                "Formula Interchange Profile 1 requires exactly 337 operations.");
        }
        return profile;
    }

    private static MathBlockFormulaProfileDescriptor CreateProfile2()
    {
        FormulaArtifactAuthority[] authority =
        [
            new("mathblocks_formula2.ocd", 867, "62B7AE087DB2799F425FFD69F93C2E83D71C5F6554F1F722CB1D876F369DCB78", true),
            new("mathblocks_formula_mappings2.xml", 147925, "7A90B818252A97208D8D8B2E219234891DF916FD7FD41CB5FF12E76A6612EAF8", true),
            new("mathblocks_formula_mappings2.rnc", 807, "717D0B7E67D4DFF232173FD55323279ACA458281BE708905DF892B8EF6AD6FD8", true),
            new("mathblocks_formula_mathml2.rnc", 968, "BADF0F363AB72F719D49DC1FD98F29B5EDD9BAD58D26DE9B2CE8F043258FA514", true),
            new("mathblocks_formula_openmath2.rnc", 1325, "59F98994C52081453EA271697F4364A220EDD80FF58574606DDBB8C6A1EFC31A", true),
            new("mathblocks_formula_operations2.ocd", 141779, "13DE49B6D91914002563EB5A9DD0FF1702F79A4FC72E3F0F7D69C71720BF203A", true),
            new("mathblocks_formula_profile2.cdg", 2144, "40CCDFDB3219C40F8020F88067276F1EA13406B73B3DF371C6CB27A9A5004037", true),
            new("mathblocks_formula_values2.ocd", 2891, "BE9D964434217E8591DD15FF70779B9422A04A797A2CECBE4738AB63320744EB", true),
            new("README.md", 4670, "F92CF76FA711CC5D4089C516D6D88D0D14512D6BF81C9B42A3251D029A9FC15B", false)
        ];
        var profile = CreateProfile(MathBlockOpenMath.Profile2, CreateArtifacts(2, authority));
        if (profile.Operations.Count != MathBlockInterchangeProfiles.Profile2OperationCount)
        {
            throw new InvalidOperationException(string.Concat(
                "Formula Interchange Profile 2 requires exactly ",
                MathBlockInterchangeProfiles.Profile2OperationCount.ToString(CultureInfo.InvariantCulture),
                " operations."));
        }
        return profile;
    }

    // The mapping of each operation follows the OpenMath profile's operation order. The
    // fingerprint binds the profile version and every ordered mapping.
    private static MathBlockFormulaProfileDescriptor CreateProfile(
        MathBlockOpenMathProfileDescriptor openMathProfile,
        IReadOnlyList<MathBlockFormulaProfileArtifact> artifacts)
    {
        var version = openMathProfile.Version;
        var contentDictionaryBase = MathBlockFormulaProfileDescriptor.PublishedContentDictionaryBase(version);
        var operationDictionary = MathBlockFormulaProfileDescriptor.OperationDictionaryName(version);
        var catalog = openMathProfile.Operations;
        var mappings = new MathBlockFormulaOperationMapping[catalog.Count];
        var fingerprintSource = new StringBuilder();
        fingerprintSource
            .Append("mathblocks-formula-profile-")
            .Append(openMathProfile.ProfileVersion)
            .Append('\n');

        for (var index = 0; index < catalog.Count; index++)
        {
            var operation = catalog[index].Operation;
            var symbol = CreateOperationSymbol(
                operation,
                contentDictionaryBase,
                operationDictionary,
                out var kind);
            var mapping = new MathBlockFormulaOperationMapping(
                operation,
                MathBlockFormulaMappingClassification.DirectMapping,
                kind,
                symbol);
            mappings[index] = mapping;

            fingerprintSource
                .Append(operation.Identity).Append('|')
                .Append((int)mapping.Classification).Append('|')
                .Append((int)kind).Append('|')
                .Append(symbol.ContentDictionaryBase).Append('|')
                .Append(symbol.Dictionary).Append('|')
                .Append(symbol.Name).Append('\n');
        }

        var fingerprint = Convert.ToHexString(
            SHA256.HashData(Encoding.UTF8.GetBytes(fingerprintSource.ToString())));
        return new MathBlockFormulaProfileDescriptor(
            openMathProfile,
            mappings,
            artifacts,
            fingerprint);
    }

    private static MathBlockFormulaProfileArtifact[] CreateArtifacts(
        int version,
        FormulaArtifactAuthority[] authority)
    {
        var suffix = version.ToString(CultureInfo.InvariantCulture);
        var resourcePrefix = string.Concat("Supprocom.MathBlocks.Formula.v", suffix, ".");
        var packageDirectory = string.Concat("formula/v", suffix, "/");
        var assembly = typeof(MathBlockFormulaInterchange).Assembly;
        var artifacts = new MathBlockFormulaProfileArtifact[authority.Length];
        for (var index = 0; index < authority.Length; index++)
        {
            artifacts[index] = CreateArtifact(
                assembly,
                resourcePrefix,
                packageDirectory,
                authority[index]);
        }
        return artifacts;
    }

    private static MathBlockFormulaProfileArtifact CreateArtifact(
        Assembly assembly,
        string resourcePrefix,
        string packageDirectory,
        FormulaArtifactAuthority authority)
    {
        using var stream = assembly.GetManifestResourceStream(
            string.Concat(resourcePrefix, authority.Name)) ??
            throw new InvalidOperationException("An embedded formula profile artifact is missing.");
        var content = new byte[authority.Length];
        stream.ReadExactly(content);
        if (stream.ReadByte() != -1 ||
!string.Equals(Convert.ToHexString(SHA256.HashData(content)), authority.Sha256, StringComparison.Ordinal))
        {
            throw new InvalidOperationException("An embedded formula profile artifact is invalid.");
        }
        return new MathBlockFormulaProfileArtifact(
            packageDirectory,
            authority.Name,
            authority.Length,
            authority.Sha256,
            authority.IsNormative,
            content);
    }

    private static MathBlockFormulaSymbol CreateOperationSymbol(
        MathBlockOperation operation,
        string contentDictionaryBase,
        string operationDictionary,
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
            contentDictionaryBase,
            operationDictionary,
            OperationSymbolName(operation.Identity));
    }

    private static string OperationSymbolName(string identity)
    {
        var separator = identity.LastIndexOf('@');
        if (separator <= 0 || separator == identity.Length - 1)
            throw new InvalidOperationException("A standard operation identity is invalid.");
        return string.Concat("op.", identity[..separator], ".v", identity[(separator + 1)..]);
    }

    private readonly record struct FormulaArtifactAuthority(
        string Name,
        int Length,
        string Sha256,
        bool IsNormative);
}
