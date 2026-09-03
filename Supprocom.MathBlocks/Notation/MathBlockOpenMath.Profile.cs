using System.Diagnostics;
using System.Reflection;
using System.Security.Cryptography;

namespace Supprocom.MathBlocks;

/// <summary>Describes one standard operation in OpenMath Profile 1.</summary>
[DebuggerDisplay("{Operation.Identity}: {Symbol.Dictionary}:{Symbol.Name}")]
public sealed class MathBlockOpenMathOperationDefinition
{
    internal MathBlockOpenMathOperationDefinition(
        MathBlockOperation operation,
        MathBlockOpenMathOperationSymbol symbol)
    {
        Operation = operation;
        Symbol = symbol;
    }

    /// <summary>Gets the exact standard operation instance.</summary>
    public MathBlockOperation Operation { get; }

    /// <summary>Gets the operation identity.</summary>
    public string Identity => Operation.Identity;

    /// <summary>Gets the operation arity.</summary>
    public int Arity => Operation.Arity;

    /// <summary>Gets the Profile 1 symbol.</summary>
    public MathBlockOpenMathOperationSymbol Symbol { get; }
}

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

public static partial class MathBlockOpenMath
{
    private const string ProfileResourcePrefix = "Supprocom.MathBlocks.OpenMath.v1.";
    private static readonly Lazy<ProfileLookupState> ProfileLookup = new(CreateProfileLookup);

    /// <summary>Gets the immutable OpenMath Profile 1 descriptor.</summary>
    public static MathBlockOpenMathProfileDescriptor Profile => ProfileLookup.Value.Descriptor;

    /// <summary>Gets the Profile 1 symbol for an exact standard operation instance.</summary>
    public static bool TryGetOperationSymbol(
        MathBlockOperation? operation,
        out MathBlockOpenMathOperationSymbol symbol)
    {
        if (operation is not null &&
            ProfileLookup.Value.SymbolsByOperation.TryGetValue(operation, out symbol))
        {
            return true;
        }
        symbol = default;
        return false;
    }

    /// <summary>Gets the exact standard operation for a Profile 1 symbol.</summary>
    public static bool TryGetOperation(
        MathBlockOpenMathOperationSymbol symbol,
        out MathBlockOperation? operation)
    {
        operation = null;
        if (symbol.Dictionary != OperationDictionary || string.IsNullOrEmpty(symbol.Name))
            return false;
        return StandardProfile.Value.OperationSymbols.TryGetValue(symbol.Name, out operation);
    }

    private static ProfileLookupState CreateProfileLookup()
    {
        var catalog = MathBlockCatalog.Standard.Operations;
        var definitions = new MathBlockOpenMathOperationDefinition[catalog.Count];
        var symbolsByOperation = new Dictionary<
            MathBlockOperation,
            MathBlockOpenMathOperationSymbol>(ReferenceEqualityComparer.Instance);
        for (var index = 0; index < catalog.Count; index++)
        {
            var operation = catalog[index];
            var symbol = new MathBlockOpenMathOperationSymbol(
                OperationDictionary,
                OperationSymbolName(operation.Identity));
            definitions[index] = new MathBlockOpenMathOperationDefinition(operation, symbol);
            symbolsByOperation.Add(operation, symbol);
        }

        ProfileArtifactAuthority[] authority =
        [
            new("mathblocks_operations1.ocd", 86876, "1123BCFF0FAF22FCC5240637418793A0723AB9675277CCA476AD166A1C49CC92", true),
            new("mathblocks_profile1.cdg", 1370, "B677CA5A6112AB185384496345CE4F7C7B3938E335E4BC998982A341CB6F4192", true),
            new("mathblocks_profile1.rnc", 5395, "9A1A89106F50103BA3490644B6042D2E5CA96C6BBAC17B2A803C36461FA75A3F", true),
            new("mathblocks_program1.ocd", 1762, "F7876109ADB4BCAE2FC6D739CEE0CF0A5AE005D1E6DE5350AA720A0E12A6D6F1", true),
            new("mathblocks_types1.ocd", 3071, "5720A943B39055610348AF6B726902F77BE3C4613578050B0FBA20890FC0612A", true),
            new("mathblocks_values1.ocd", 3154, "6B86128D78B6778B0271930301BD98D02C20CA889782F7F0AAFA02CF72FE73E9", true),
            new("README.md", 2510, "522A1429F19E642345A09BBAEE1EA0E3DC8631F873269D4E07486519A51E7FE8", false)
        ];
        var artifacts = new MathBlockOpenMathProfileArtifact[authority.Length];
        var assembly = typeof(MathBlockOpenMath).Assembly;
        for (var index = 0; index < authority.Length; index++)
            artifacts[index] = CreateArtifact(assembly, authority[index]);

        return new ProfileLookupState(
            new MathBlockOpenMathProfileDescriptor(definitions, artifacts),
            symbolsByOperation);
    }

    private static MathBlockOpenMathProfileArtifact CreateArtifact(
        Assembly assembly,
        ProfileArtifactAuthority authority)
    {
        using var stream = assembly.GetManifestResourceStream(
            string.Concat(ProfileResourcePrefix, authority.Name)) ??
            throw new InvalidOperationException("An embedded OpenMath profile artifact is missing.");
        var content = new byte[authority.Length];
        stream.ReadExactly(content);
        if (stream.ReadByte() != -1 ||
            Convert.ToHexString(SHA256.HashData(content)) != authority.Sha256)
        {
            throw new InvalidOperationException("An embedded OpenMath profile artifact is invalid.");
        }
        return new MathBlockOpenMathProfileArtifact(
            authority.Name,
            authority.Length,
            authority.Sha256,
            authority.IsNormative,
            content);
    }

    private sealed record ProfileLookupState(
        MathBlockOpenMathProfileDescriptor Descriptor,
        IReadOnlyDictionary<MathBlockOperation, MathBlockOpenMathOperationSymbol>
            SymbolsByOperation);

    private readonly record struct ProfileArtifactAuthority(
        string Name,
        int Length,
        string Sha256,
        bool IsNormative);
}
