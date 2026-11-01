using System.Globalization;
using System.Reflection;
using System.Security.Cryptography;

namespace Supprocom.MathBlocks;

public static partial class MathBlockOpenMath
{
    private const string OutsideProfileKey = "MathBlocks.OpenMath.OutsideProfile";
    private static readonly Lazy<MathBlockOpenMathProfileDescriptor> Profile1State =
        new(CreateProfile1);
    private static readonly Lazy<MathBlockOpenMathProfileDescriptor> Profile2State =
        new(CreateProfile2);
    private static readonly Lazy<MathBlockOpenMathProfileDescriptor>[] PublishedProfiles =
        [Profile1State, Profile2State];
    private static readonly Lazy<IReadOnlyList<MathBlockOpenMathProfileDescriptor>> ProfileList =
        new(() => Array.AsReadOnly(new[] { Profile1State.Value, Profile2State.Value }));

    /// <summary>Gets the immutable OpenMath Profile 1 descriptor.</summary>
    public static MathBlockOpenMathProfileDescriptor Profile => Profile1State.Value;

    /// <summary>Gets the immutable OpenMath Profile 2 descriptor.</summary>
    public static MathBlockOpenMathProfileDescriptor Profile2 => Profile2State.Value;

    /// <summary>Gets every supported OpenMath profile in ascending version order.</summary>
    public static IReadOnlyList<MathBlockOpenMathProfileDescriptor> Profiles => ProfileList.Value;

    /// <summary>Gets the Profile 1 symbol for an exact standard operation instance.</summary>
    public static bool TryGetOperationSymbol(
        MathBlockOperation? operation,
        out MathBlockOpenMathOperationSymbol symbol) =>
        Profile.TryGetOperationSymbol(operation, out symbol);

    /// <summary>Gets the exact standard operation for a Profile 1 symbol.</summary>
    public static bool TryGetOperation(
        MathBlockOpenMathOperationSymbol symbol,
        out MathBlockOperation? operation) =>
        Profile.TryGetOperation(symbol, out operation);

    /// <summary>Gets the lowest supported profile that contains every operation of a program.</summary>
    public static MathBlockOpenMathProfileDescriptor SelectProfile(MathBlockProgram program)
    {
        ArgumentNullException.ThrowIfNull(program);
        return SelectProfile(program, PublishedProfiles);
    }

    // Creates a profile over every operation of a registry, without embedded artifacts. Only the
    // published profiles are reachable through the public API.
    internal static MathBlockOpenMathProfileDescriptor CreateUnpublishedProfile(
        int version,
        MathBlockRegistry registry)
    {
        ArgumentNullException.ThrowIfNull(registry);
        ArgumentOutOfRangeException.ThrowIfLessThan(version, 1);
        return new MathBlockOpenMathProfileDescriptor(
            version,
            registry,
            MathBlockCollectionPrimitives.Copy(registry.Operations),
            []);
    }

    internal static Lazy<MathBlockOpenMathProfileDescriptor>[] CreateCandidates(
        MathBlockOpenMathProfileDescriptor[] profiles)
    {
        ArgumentNullException.ThrowIfNull(profiles);
        if (profiles.Length == 0)
            throw new ArgumentException("At least one OpenMath profile is required.", nameof(profiles));
        var result = new Lazy<MathBlockOpenMathProfileDescriptor>[profiles.Length];
        for (var index = 0; index < result.Length; index++)
        {
            var profile = profiles[index] ??
                throw new ArgumentException("An OpenMath profile is null.", nameof(profiles));
            result[index] = new Lazy<MathBlockOpenMathProfileDescriptor>(profile);
        }
        return result;
    }

    internal static MathBlockOpenMathProfileDescriptor SelectProfile(
        MathBlockProgram program,
        MathBlockOpenMathProfileDescriptor[] profiles)
    {
        ArgumentNullException.ThrowIfNull(program);
        return SelectProfile(program, CreateCandidates(profiles));
    }

    // Profiles are tried in ascending order, so a program that a lower profile covers never
    // constructs a higher one.
    internal static MathBlockOpenMathProfileDescriptor SelectProfile(
        MathBlockProgram program,
        Lazy<MathBlockOpenMathProfileDescriptor>[] profiles)
    {
        MathBlockOpenMathProfileDescriptor? highest = null;
        for (var index = 0; index < profiles.Length; index++)
        {
            highest = profiles[index].Value;
            if (FindOperationOutside(program, highest) < 0)
                return highest;
        }
        throw OutsideProfile(program, highest!, true);
    }

    private static void RequireProfileOperations(
        MathBlockProgram program,
        MathBlockOpenMathProfileDescriptor profile)
    {
        if (FindOperationOutside(program, profile) >= 0)
            throw OutsideProfile(program, profile, false);
    }

    private static int FindOperationOutside(
        MathBlockProgram program,
        MathBlockOpenMathProfileDescriptor profile)
    {
        var nodes = program.Nodes;
        for (var index = 0; index < nodes.Length; index++)
        {
            var node = nodes[index];
            if (node.Kind == MathBlockProgramBuilder.NodeKind.Operation &&
                !profile.Contains(node.Operation))
            {
                return index;
            }
        }
        return -1;
    }

    private static InvalidOperationException OutsideProfile(
        MathBlockProgram program,
        MathBlockOpenMathProfileDescriptor profile,
        bool highest)
    {
        var index = FindOperationOutside(program, profile);
        var identity = index < 0 ? null : program.Nodes[index].Operation?.Identity;
        var target = string.Concat("MathBlocks OpenMath Profile ", profile.ProfileVersion);
        var exception = new InvalidOperationException(identity is null
            ? string.Concat("The program contains an operation outside ", target, ".")
            : string.Concat(
                "The program contains operation '",
                identity,
                "', which is outside ",
                target,
                highest ? ", the highest supported profile." : "."));
        exception.Data[OutsideProfileKey] = profile.ProfileVersion;
        if (identity is not null)
            exception.Data[DiagnosticOperationKey] = identity;
        if (index >= 0)
            exception.Data[DiagnosticNodeKey] = index;
        return exception;
    }

    private static MathBlockOpenMathProfileDescriptor CreateProfile1()
    {
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
        return new MathBlockOpenMathProfileDescriptor(
            1,
            MathBlockCatalog.Standard,
            MathBlockInterchangeProfiles.ResolveProfile1(MathBlockCatalog.Standard),
            CreateArtifacts(1, authority));
    }

    private static MathBlockOpenMathProfileDescriptor CreateProfile2()
    {
        ProfileArtifactAuthority[] authority =
        [
            new("mathblocks_operations2.ocd", 143352, "1160BFA7A08EAAEFC2FB475B1F88557AADB906938404DFE00184D36B3F045F1C", true),
            new("mathblocks_profile2.cdg", 1370, "5EC3D86461075E19A8EF0D9D88425C90B3F50A145D361421947818185C6630C8", true),
            new("mathblocks_profile2.rnc", 5395, "CB0F2C3759D8CAB0BA19776F7E81F30EEC1A2F84864267360ED79E95CE0A9439", true),
            new("mathblocks_program2.ocd", 1762, "B59D09667FC6F8C11E640B3215F9FF2F0620DB27D0AABEA19F44F23E15A69D7C", true),
            new("mathblocks_types2.ocd", 3071, "5B4EAC67F2FC62575D202E6FD918F362E765012FF70959FA555D76E5C441BF55", true),
            new("mathblocks_values2.ocd", 3154, "1A6786C2F809CD4F9476FA4605A7C72937746870F782EF2D49CB2D76E44AB36C", true)
        ];
        return new MathBlockOpenMathProfileDescriptor(
            2,
            MathBlockCatalog.Standard,
            MathBlockInterchangeProfiles.ResolveProfile2(MathBlockCatalog.Standard),
            CreateArtifacts(2, authority));
    }

    private static MathBlockOpenMathProfileArtifact[] CreateArtifacts(
        int version,
        ProfileArtifactAuthority[] authority)
    {
        var suffix = version.ToString(CultureInfo.InvariantCulture);
        var resourcePrefix = string.Concat("Supprocom.MathBlocks.OpenMath.v", suffix, ".");
        var packageDirectory = string.Concat("openmath/v", suffix, "/");
        var assembly = typeof(MathBlockOpenMath).Assembly;
        var artifacts = new MathBlockOpenMathProfileArtifact[authority.Length];
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

    private static MathBlockOpenMathProfileArtifact CreateArtifact(
        Assembly assembly,
        string resourcePrefix,
        string packageDirectory,
        ProfileArtifactAuthority authority)
    {
        using var stream = assembly.GetManifestResourceStream(
            string.Concat(resourcePrefix, authority.Name)) ??
            throw new InvalidOperationException("An embedded OpenMath profile artifact is missing.");
        var content = new byte[authority.Length];
        stream.ReadExactly(content);
        if (stream.ReadByte() != -1 ||
!string.Equals(Convert.ToHexString(SHA256.HashData(content)), authority.Sha256, StringComparison.Ordinal))
        {
            throw new InvalidOperationException("An embedded OpenMath profile artifact is invalid.");
        }
        return new MathBlockOpenMathProfileArtifact(
            packageDirectory,
            authority.Name,
            authority.Length,
            authority.Sha256,
            authority.IsNormative,
            content);
    }

    private readonly record struct ProfileArtifactAuthority(
        string Name,
        int Length,
        string Sha256,
        bool IsNormative);
}
