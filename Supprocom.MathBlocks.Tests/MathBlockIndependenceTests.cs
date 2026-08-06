using System.Reflection;
using System.Reflection.Metadata;
using System.Reflection.PortableExecutable;
using System.Runtime.CompilerServices;
using System.Text.RegularExpressions;
using System.Xml.Linq;
using Supprocom.MathBlocks;

namespace Supprocom.MathBlocks.Tests;

public sealed partial class MathBlockIndependenceTests
{
    [Fact]
    public void Production_project_has_no_project_or_managed_library_dependencies()
    {
        var root = FindRepositoryRoot();
        var projectPath = Path.Combine(root, "Supprocom.MathBlocks", "Supprocom.MathBlocks.csproj");
        var document = XDocument.Load(projectPath);

        Assert.Empty(document.Descendants("ProjectReference"));
        Assert.Equal(
            [
                "TorchSharp-cuda-linux@[0.107.0]",
                "libtorch-cuda-12.8-win-x64-part1@[2.10.0]",
                "libtorch-cuda-12.8-win-x64-part8@[2.10.0]"
            ],
            document.Descendants("PackageReference")
                .Select(reference =>
                    $"{reference.Attribute("Include")!.Value}@{reference.Attribute("Version")!.Value}")
                .OrderBy(value => value, StringComparer.Ordinal));
        Assert.All(document.Descendants("PackageReference"), reference =>
        {
            Assert.Null(reference.Attribute("Condition"));
            Assert.Null(reference.Parent!.Attribute("Condition"));
        });
        Assert.All(typeof(MathBlockCatalog).Assembly.GetReferencedAssemblies(), reference =>
            Assert.StartsWith("System", reference.Name, StringComparison.Ordinal));
    }

    [Fact]
    public void Public_release_metadata_declares_the_CUDA_0_2_3_contract()
    {
        var root = FindRepositoryRoot();
        var projectPath = Path.Combine(root, "Supprocom.MathBlocks", "Supprocom.MathBlocks.csproj");
        var document = XDocument.Load(projectPath);
        var readme = File.ReadAllText(Path.Combine(root, "README.md"));

        Assert.Equal("0.2.3", document.Descendants("Version").Single().Value);
        Assert.Equal("AGPL-3.0-only", document.Descendants("PackageLicenseExpression").Single().Value);
        Assert.Contains(
            "Rejects statically infeasible catalog programs before CUDA work",
            document.Descendants("PackageReleaseNotes").Single().Value,
            StringComparison.Ordinal);
        Assert.Equal(new Version(0, 2, 3, 0), typeof(MathBlockCatalog).Assembly.GetName().Version);
        Assert.Contains("## Parallel proposal waves", readme, StringComparison.Ordinal);
        Assert.Contains(
            "dotnet add package Supprocom.MathBlocks --version 0.2.3",
            readme,
            StringComparison.Ordinal);
        Assert.DoesNotContain("--version 0.1.", readme, StringComparison.Ordinal);
    }

    [Fact]
    public void Public_tree_uses_only_CUDA_accelerator_identity()
    {
        var root = FindRepositoryRoot();
        var legacyToken = string.Concat('g', 'p', 'u');
        var requiredVendorOption = $"--{legacyToken}-architecture";
        var failures = new List<string>();
        var vendorOptionCount = 0;
        var publicRoots = new[]
        {
            Path.Combine(root, "README.md"),
            Path.Combine(root, "THIRD-PARTY-NOTICES.md"),
            Path.Combine(root, "Supprocom.MathBlocks"),
            Path.Combine(root, "Supprocom.MathBlocks.Tests")
        };

        foreach (var publicRoot in publicRoots)
        {
            if (File.Exists(publicRoot))
            {
                InspectFile(publicRoot);
                continue;
            }

            foreach (var file in Directory.EnumerateFiles(publicRoot, "*", SearchOption.AllDirectories))
            {
                if (IsBuildOutput(publicRoot, file))
                    continue;
                InspectFile(file);
            }
        }

        Assert.Equal(1, vendorOptionCount);
        Assert.Empty(failures);
        return;

        void InspectFile(string file)
        {
            var relative = Path.GetRelativePath(root, file);
            if (relative.Contains(legacyToken, StringComparison.OrdinalIgnoreCase))
                failures.Add(relative);

            var source = File.ReadAllText(file);
            var optionIndex = source.IndexOf(requiredVendorOption, StringComparison.Ordinal);
            if (optionIndex >= 0)
            {
                vendorOptionCount++;
                source = source.Remove(optionIndex, requiredVendorOption.Length);
            }
            if (source.Contains(legacyToken, StringComparison.OrdinalIgnoreCase))
                failures.Add(relative);
        }
    }

    [Fact]
    public void Production_source_contains_no_input_or_factor_semantics()
    {
        var root = FindRepositoryRoot();
        var sourceRoot = Path.Combine(root, "Supprocom.MathBlocks");
        var failures = new List<string>();
        foreach (var file in Directory.EnumerateFiles(sourceRoot, "*.cs", SearchOption.AllDirectories))
        {
            if (IsBuildOutput(sourceRoot, file))
                continue;
            var text = File.ReadAllText(file);
            foreach (Match match in ForbiddenSemanticWord().Matches(text))
                failures.Add($"{Path.GetFileName(file)}: {match.Value}");
            var relative = Path.GetRelativePath(sourceRoot, file);
            var isNativeInfrastructure = relative.StartsWith($"Cuda{Path.DirectorySeparatorChar}", StringComparison.Ordinal) ||
                                         relative == Path.Combine("Execution", "MathBlocksCUDAWorker.cs");
            if (!isNativeInfrastructure)
                foreach (Match match in ForbiddenEffectWord().Matches(text))
                    failures.Add($"{Path.GetFileName(file)}: {match.Value}");
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures));
    }

    [Fact]
    public void Public_contract_exposes_only_mathblock_and_system_types()
    {
        var assembly = typeof(MathBlockCatalog).Assembly;
        var foreignTypes = assembly.ExportedTypes
            .SelectMany(type => type.GetMembers(BindingFlags.Public | BindingFlags.Instance | BindingFlags.Static))
            .SelectMany(MemberTypes)
            .Where(type => type is not null)
            .Select(type => type!)
            .Where(type => type.Namespace is not null &&
                           !type.Namespace.StartsWith("System", StringComparison.Ordinal) &&
                           !type.Namespace.StartsWith("Supprocom.MathBlocks", StringComparison.Ordinal))
            .Distinct()
            .ToArray();

        Assert.Empty(foreignTypes);
    }

    [Fact]
    public void Production_math_calls_resolve_to_owned_low_level_primitives()
    {
        var root = FindRepositoryRoot();
        var sourceRoot = Path.Combine(root, "Supprocom.MathBlocks");
        var aliasPath = Path.Combine(sourceRoot, "GlobalUsings.cs");
        var alias = File.ReadAllText(aliasPath);
        var systemMathReferences = new List<string>();
        foreach (var file in Directory.EnumerateFiles(sourceRoot, "*.cs", SearchOption.AllDirectories))
        {
            if (IsBuildOutput(sourceRoot, file))
                continue;
            var source = File.ReadAllText(file);
            if (Regex.IsMatch(source, @"\bSystem\.Math\b", RegexOptions.CultureInvariant))
                systemMathReferences.Add(Path.GetRelativePath(sourceRoot, file));
        }

        Assert.Contains(
            "global using Math = Supprocom.MathBlocks.MathBlockPrimitives;",
            alias,
            StringComparison.Ordinal);
        Assert.Empty(systemMathReferences);
    }

    [Fact]
    public void Production_binary_has_no_System_Math_member_reference()
    {
        using var stream = File.OpenRead(typeof(MathBlockCatalog).Assembly.Location);
        using var executable = new PEReader(stream);
        var metadata = executable.GetMetadataReader();
        var references = new List<string>();
        foreach (var handle in metadata.MemberReferences)
        {
            var member = metadata.GetMemberReference(handle);
            if (member.Parent.Kind != HandleKind.TypeReference)
                continue;
            var type = metadata.GetTypeReference((TypeReferenceHandle)member.Parent);
            if (metadata.GetString(type.Namespace) == "System" && metadata.GetString(type.Name) == "Math")
                references.Add(metadata.GetString(member.Name));
        }

        Assert.Empty(references);
    }

    [Fact]
    public void Production_binary_has_no_System_Linq_Enumerable_member_reference()
    {
        using var stream = File.OpenRead(typeof(MathBlockCatalog).Assembly.Location);
        using var executable = new PEReader(stream);
        var metadata = executable.GetMetadataReader();
        var references = new List<string>();
        foreach (var handle in metadata.MemberReferences)
        {
            var member = metadata.GetMemberReference(handle);
            if (member.Parent.Kind != HandleKind.TypeReference)
                continue;
            var type = metadata.GetTypeReference((TypeReferenceHandle)member.Parent);
            if (metadata.GetString(type.Namespace) == "System.Linq" &&
                metadata.GetString(type.Name) == "Enumerable")
            {
                references.Add(metadata.GetString(member.Name));
            }
        }

        Assert.Empty(references);
    }

    [Fact]
    public void Production_source_has_no_library_collection_algorithms()
    {
        var root = FindRepositoryRoot();
        var sourceRoot = Path.Combine(root, "Supprocom.MathBlocks");
        var forbidden = new[]
        {
            "Array.Sort(",
            "Array.Copy(",
            "Array.Clear(",
            "Array.Fill(",
            "System.Numerics.BitOperations",
            "BitConverter."
        };
        var failures = new List<string>();
        foreach (var file in Directory.EnumerateFiles(sourceRoot, "*.cs", SearchOption.AllDirectories))
        {
            if (IsBuildOutput(sourceRoot, file) ||
                file.EndsWith(".Tests.cs", StringComparison.Ordinal))
                continue;
            var source = File.ReadAllText(file);
            foreach (var value in forbidden)
                if (source.Contains(value, StringComparison.Ordinal))
                    failures.Add($"{Path.GetRelativePath(sourceRoot, file)}: {value}");
        }

        Assert.Empty(failures);
    }

    [Fact]
    public void Production_binary_has_no_System_Numerics_type_reference()
    {
        using var stream = File.OpenRead(typeof(MathBlockCatalog).Assembly.Location);
        using var executable = new PEReader(stream);
        var metadata = executable.GetMetadataReader();
        var references = new List<string>();
        foreach (var handle in metadata.TypeReferences)
        {
            var type = metadata.GetTypeReference(handle);
            if (metadata.GetString(type.Namespace).StartsWith("System.Numerics", StringComparison.Ordinal))
                references.Add(metadata.GetString(type.Name));
        }

        Assert.Empty(references);
    }

    private static IEnumerable<Type?> MemberTypes(MemberInfo member) => member switch
    {
        MethodInfo method => method.GetParameters().Select(parameter => Unwrap(parameter.ParameterType))
            .Append(Unwrap(method.ReturnType)),
        ConstructorInfo constructor => constructor.GetParameters().Select(parameter => Unwrap(parameter.ParameterType)),
        PropertyInfo property => [Unwrap(property.PropertyType)],
        FieldInfo field => [Unwrap(field.FieldType)],
        _ => []
    };

    private static Type Unwrap(Type type)
    {
        while (type.HasElementType)
            type = type.GetElementType()!;
        if (type.IsGenericType)
            return type.GetGenericTypeDefinition();
        return type;
    }

    private static bool IsBuildOutput(string sourceRoot, string file)
    {
        var relative = Path.GetRelativePath(sourceRoot, file);
        return relative.StartsWith($"bin{Path.DirectorySeparatorChar}", StringComparison.Ordinal) ||
               relative.StartsWith($"obj{Path.DirectorySeparatorChar}", StringComparison.Ordinal);
    }

    private static string FindRepositoryRoot([CallerFilePath] string sourceFile = "")
    {
        foreach (var start in new[] { Path.GetDirectoryName(sourceFile)!, Directory.GetCurrentDirectory(), AppContext.BaseDirectory })
        {
            var directory = new DirectoryInfo(start);
            while (directory is not null)
            {
                if (Directory.Exists(Path.Combine(directory.FullName, ".git")) &&
                    Directory.Exists(Path.Combine(directory.FullName, "Supprocom.MathBlocks")))
                    return directory.FullName;
                directory = directory.Parent;
            }
        }
        throw new DirectoryNotFoundException("The repository root was not found.");
    }

    [GeneratedRegex(@"\b(?:Canonical|Factor|Market|Price|Volume|Volatility|Frame|Trade|Trading|Bet|Betting|Candle|Timestamp|Binance|Polymarket)\b", RegexOptions.IgnoreCase)]
    private static partial Regex ForbiddenSemanticWord();

    [GeneratedRegex(@"\b(?:DateTime|DateTimeOffset|Random|Guid|Environment|File|Directory|HttpClient|Thread|Task|Process)\b")]
    private static partial Regex ForbiddenEffectWord();
}
