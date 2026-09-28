using System.Reflection;
using System.Reflection.Metadata;
using System.Reflection.PortableExecutable;
using System.Runtime.CompilerServices;
using System.Text.RegularExpressions;
using System.Xml.Linq;
using Markdig;
using Markdig.Extensions.Tables;
using Markdig.Syntax;
using Markdig.Syntax.Inlines;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Contains regression tests for Math Block Independence Tests.</summary>
public sealed partial class MathBlockIndependenceTests
{
    private static readonly MarkdownPipeline ReadmePipeline =
        new MarkdownPipelineBuilder().UsePipeTables().Build();

    /// <summary>Verifies production project has no project reference or unapproved managed dependencies.</summary>
    [Fact]
    public void ProductionProjectHasNoProjectReferenceOrUnapprovedManagedDependencies()
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
                .Order(StringComparer.Ordinal), StringComparer.Ordinal);
        Assert.All(document.Descendants("PackageReference"), reference =>
        {
            Assert.Null(reference.Attribute("Condition"));
            Assert.Null(reference.Parent!.Attribute("Condition"));
        });
        Assert.All(typeof(MathBlockCatalog).Assembly.GetReferencedAssemblies(), reference =>
        {
            var name = reference.Name ?? string.Empty;
            Assert.True(
                name.StartsWith("System", StringComparison.Ordinal),
                $"Unexpected managed dependency '{name}'.");
        });
    }

    /// <summary>Verifies cudasource generator uses exact public csharp 2 cudadependency.</summary>
    [Fact]
    public void CUDASourceGeneratorUsesExactPublicCSharp2CUDADependency()
    {
        var root = FindRepositoryRoot();
        var projectPath = Path.Combine(
            root,
            "MathBlocks.CudaSourceGenerator",
            "MathBlocks.CudaSourceGenerator.csproj");
        var sourcePath = Path.Combine(
            root,
            "MathBlocks.CudaSourceGenerator",
            "Program.cs");
        var document = XDocument.Load(projectPath);
        var package = Assert.Single(document.Descendants("PackageReference"));

        Assert.Empty(document.Descendants("ProjectReference"));
        Assert.Equal("Supprocom.CSharp2CUDA", package.Attribute("Include")!.Value);
        Assert.Equal("[0.3.1]", package.Attribute("Version")!.Value);
        Assert.Null(package.Attribute("Condition"));
        Assert.Null(package.Parent!.Attribute("Condition"));

        var translationRoot = Path.Combine(
            root,
            "MathBlocks.CudaSourceGenerator",
            "TranslationUnits");
        var translationSources = Directory.EnumerateFiles(
                translationRoot,
                "*Module.cs",
                SearchOption.TopDirectoryOnly)
            .Order(StringComparer.Ordinal)
            .ToArray();
        Assert.Equal(12, translationSources.Length);
        var runtimeCudaBlocks = Path.Combine(
            root,
            "Supprocom.MathBlocks",
            "Cuda",
            "Blocks");
        Assert.False(
            Directory.Exists(runtimeCudaBlocks) &&
            Directory.EnumerateFiles(
                runtimeCudaBlocks,
                "*CudaBlockCatalog.cs",
                SearchOption.AllDirectories).Any());

        foreach (var source in translationSources.Append(sourcePath))
        {
            var text = File.ReadAllText(source);
            Assert.Contains("using Supprocom.CSharp2CUDA;", text, StringComparison.Ordinal);
            Assert.DoesNotContain("using CSharp2CUDA;", text, StringComparison.Ordinal);
        }

        foreach (var source in translationSources)
        {
            var text = File.ReadAllText(source);
            Assert.Contains("[TranspileToCUDA]", text, StringComparison.Ordinal);
            Assert.DoesNotContain("[CudaTranslationUnit]", text, StringComparison.Ordinal);
            Assert.DoesNotContain("TranslationUnitSource", text, StringComparison.Ordinal);
        }

        var operationSources = translationSources
            .Where(path => !path.EndsWith("DeviceDispatchModule.cs", StringComparison.Ordinal))
            .ToArray();
        Assert.Equal(11, operationSources.Length);
        Assert.All(operationSources, source =>
        {
            var text = File.ReadAllText(source);
            Assert.Contains("[CudaDevice(Name = \"mathblocks_", text, StringComparison.Ordinal);
            Assert.DoesNotContain("[CudaGlobal]", text, StringComparison.Ordinal);
            Assert.DoesNotContain("Cuda.BlockIdx.X", text, StringComparison.Ordinal);
        });

        var generatorSource = File.ReadAllText(sourcePath);
        Assert.Contains("CudaTranspiler.TranspileFile(", generatorSource, StringComparison.Ordinal);
        Assert.Contains("--translation-root", generatorSource, StringComparison.Ordinal);
        Assert.DoesNotContain("ToDeviceSource", generatorSource, StringComparison.Ordinal);
        Assert.DoesNotContain("ExtractTranslationUnit", generatorSource, StringComparison.Ordinal);
        Assert.DoesNotContain("TranslationUnitSource", generatorSource, StringComparison.Ordinal);
        Assert.DoesNotContain("extern \"C\" __global__", generatorSource, StringComparison.Ordinal);
        Assert.DoesNotContain("blockIdx.x", generatorSource, StringComparison.Ordinal);
        Assert.Equal(
            11,
            operationSources.Count(path =>
                File.ReadAllText(path).Contains("[CudaDevice(Name = \"mathblocks_", StringComparison.Ordinal)));
    }

    /// <summary>Verifies repository cibuilds the direct cudasource contract.</summary>
    [Fact]
    public void RepositoryCIBuildsTheDirectCUDASourceContract()
    {
        var root = FindRepositoryRoot();
        var workflowPath = Path.Combine(root, ".github", "workflows", "ci.yml");

        Assert.True(File.Exists(workflowPath), "The repository CI workflow is missing.");
        var workflow = File.ReadAllText(workflowPath);
        Assert.Contains("push:", workflow, StringComparison.Ordinal);
        Assert.Contains("pull_request:", workflow, StringComparison.Ordinal);
        Assert.Contains("workflow_dispatch:", workflow, StringComparison.Ordinal);
        Assert.Contains("dotnet restore", workflow, StringComparison.Ordinal);
        Assert.Contains("NuGetAuditMode=all", workflow, StringComparison.Ordinal);
        Assert.Contains("dotnet build", workflow, StringComparison.Ordinal);
        Assert.Contains("--warnaserror", workflow, StringComparison.Ordinal);
        Assert.Contains("git diff --check", workflow, StringComparison.Ordinal);
        Assert.Contains("TranslationUnits", workflow, StringComparison.Ordinal);
        Assert.Contains("ToDeviceSource", workflow, StringComparison.Ordinal);
        Assert.Contains("mathml3-relaxng.zip", workflow, StringComparison.Ordinal);
        Assert.Contains("mathblocks_formula_mappings1.rnc", workflow, StringComparison.Ordinal);
        Assert.Contains("classification=\"direct-mapping\"", workflow, StringComparison.Ordinal);
        Assert.Contains("Run the notation coverage-guided smoke gate", workflow, StringComparison.Ordinal);
        Assert.Contains("Compile generated CUDA source with NVRTC", workflow, StringComparison.Ordinal);
        Assert.Contains("MathBlockFormulaInterchange", workflow, StringComparison.Ordinal);
        Assert.Contains("dotnet pack", workflow, StringComparison.Ordinal);
        Assert.Contains("ExpectedRepositoryCommit", workflow, StringComparison.Ordinal);
        Assert.Contains("Supprocom.MathBlocks.ExternalConsumer", workflow, StringComparison.Ordinal);
        Assert.Contains("SHA256SUMS", workflow, StringComparison.Ordinal);
        Assert.Contains("windows-latest", workflow, StringComparison.Ordinal);

        var attributes = File.ReadAllText(Path.Combine(root, ".gitattributes"));
        Assert.Contains("formula/v1/* text eol=lf", attributes, StringComparison.Ordinal);
    }

    /// <summary>Verifies public release metadata declares the 051 contract.</summary>
    [Fact]
    public void PublicReleaseMetadataDeclaresThe052Contract()
    {
        var root = FindRepositoryRoot();
        var projectPath = Path.Combine(root, "Supprocom.MathBlocks", "Supprocom.MathBlocks.csproj");
        var document = XDocument.Load(projectPath);
        var readme = File.ReadAllText(Path.Combine(root, "README.md"));
        var apiGuide = File.ReadAllText(Path.Combine(root, "docs", "openmath-api.md"));
        var formulaGuide = File.ReadAllText(
            Path.Combine(root, "docs", "formula-interchange-api.md"));
        var programmingGuide = File.ReadAllText(
            Path.Combine(root, "docs", "programming-model.md"));
        var cudaGuide = File.ReadAllText(
            Path.Combine(root, "docs", "cuda-integration.md"));
        var developmentGuide = File.ReadAllText(
            Path.Combine(root, "docs", "development.md"));

        Assert.Equal("0.5.2", document.Descendants("Version").Single().Value);
        Assert.Equal("AGPL-3.0-only", document.Descendants("PackageLicenseExpression").Single().Value);
        Assert.Equal("true", document.Descendants("PublishRepositoryUrl").Single().Value);
        Assert.Contains(
            "ExpectedRepositoryCommit",
            File.ReadAllText(projectPath),
            StringComparison.Ordinal);
        Assert.Contains(
            "337-operation OpenMath and Content MathML interchange",
            document.Descendants("PackageReleaseNotes").Single().Value,
            StringComparison.Ordinal);
        Assert.Equal(new Version(0, 5, 2, 0), typeof(MathBlockCatalog).Assembly.GetName().Version);
        Assert.Contains("## Build a program", readme, StringComparison.Ordinal);
        Assert.Contains("## Exchange formulas", readme, StringComparison.Ordinal);
        Assert.Contains("## Choose an API", readme, StringComparison.Ordinal);
        Assert.Contains("## Documentation", readme, StringComparison.Ordinal);
        Assert.Contains("## Build from source", readme, StringComparison.Ordinal);
        Assert.Contains(
            "dotnet add package Supprocom.MathBlocks --version 0.5.2",
            readme,
            StringComparison.Ordinal);
        AssertReadmeUsesOneParagraphAndOneSupplementPerSection(readme);
        AssertPackageReadmeUsesImmutableLinks(readme);
        Assert.Equal("README.md", document.Descendants("PackageReadmeFile").Single().Value);
        Assert.Contains(
            document.Descendants("None"),
            item => string.Equals(item.Attribute("Include")?.Value, "..\\README.md", StringComparison.Ordinal) &&
string.Equals(item.Attribute("PackagePath")?.Value, "README.md", StringComparison.Ordinal));
        Assert.Contains("## Diagnostic codes", apiGuide, StringComparison.Ordinal);
        Assert.Contains("## Security boundary", apiGuide, StringComparison.Ordinal);
        Assert.Contains("## Total operation mapping", formulaGuide, StringComparison.Ordinal);
        Assert.Contains("## Canonical and security boundary", formulaGuide, StringComparison.Ordinal);
        Assert.Contains("## Operation contracts", programmingGuide, StringComparison.Ordinal);
        Assert.Contains("## CPU execution", programmingGuide, StringComparison.Ordinal);
        Assert.Contains("## Consumer-owned kernels", cudaGuide, StringComparison.Ordinal);
        Assert.Contains("## Performance contract", cudaGuide, StringComparison.Ordinal);
        Assert.Contains("## Build and test", developmentGuide, StringComparison.Ordinal);
        Assert.Contains("## Package validation", developmentGuide, StringComparison.Ordinal);
        Assert.Contains(
            document.Descendants("None"),
            item => string.Equals(item.Attribute("Include")?.Value, "..\\docs\\openmath-api.md", StringComparison.Ordinal) &&
string.Equals(item.Attribute("PackagePath")?.Value, "docs/openmath-api.md", StringComparison.Ordinal));
        Assert.Contains(
            document.Descendants("None"),
            item => string.Equals(item.Attribute("Include")?.Value, "..\\docs\\formula-interchange-api.md", StringComparison.Ordinal) &&
string.Equals(item.Attribute("PackagePath")?.Value, "docs/formula-interchange-api.md", StringComparison.Ordinal));
        Assert.Contains(
            document.Descendants("None"),
            item => string.Equals(item.Attribute("Include")?.Value, "..\\docs\\programming-model.md", StringComparison.Ordinal) &&
string.Equals(item.Attribute("PackagePath")?.Value, "docs/programming-model.md", StringComparison.Ordinal));
        Assert.Contains(
            document.Descendants("None"),
            item => string.Equals(item.Attribute("Include")?.Value, "..\\docs\\cuda-integration.md", StringComparison.Ordinal) &&
string.Equals(item.Attribute("PackagePath")?.Value, "docs/cuda-integration.md", StringComparison.Ordinal));
        Assert.Contains(
            document.Descendants("None"),
            item => string.Equals(item.Attribute("Include")?.Value, "..\\docs\\development.md", StringComparison.Ordinal) &&
string.Equals(item.Attribute("PackagePath")?.Value, "docs/development.md", StringComparison.Ordinal));
        Assert.DoesNotContain("## Resident typed program search", readme, StringComparison.Ordinal);
        Assert.DoesNotContain("## Parallel proposal waves", readme, StringComparison.Ordinal);
    }

    /// <summary>Verifies readmestructure policy rejects common mark bypasses.</summary>
    [Theory]
    [InlineData("# Example\n\n## Section\n\n1) ordered item")]
    [InlineData("# Example\n\n## Section\n\n~~~text\nfirst\n~~~\n\n| Value |\n| --- |\n| second |")]
    [InlineData("# Example\n\n## Section\n\n    first\n\n| Value |\n| --- |\n| second |")]
    public void READMEStructurePolicyRejectsCommonMarkBypasses(string source)
    {
        Assert.NotEmpty(GetReadmeStructureErrors(source));
    }

    /// <summary>Verifies readmestructure policy accepts one common mark code supplement.</summary>
    [Theory]
    [InlineData("# Example\n\n## Section\n\n~~~text\nvalue\n~~~")]
    [InlineData("# Example\n\n## Section\n\n    value")]
    public void READMEStructurePolicyAcceptsOneCommonMarkCodeSupplement(string source)
    {
        Assert.Empty(GetReadmeStructureErrors(source));
    }

    /// <summary>Verifies package readmelink policy rejects nonimmutable targets.</summary>
    [Theory]
    [InlineData("[guide](docs/development.md)")]
    [InlineData("[guide](../docs/development.md)")]
    [InlineData("[guide](http://github.com/Supprocom/MathBlocks)")]
    public void PackageREADMELinkPolicyRejectsNonimmutableTargets(string source)
    {
        Assert.NotEmpty(GetPackageReadmeLinkErrors(source));
    }

    /// <summary>Verifies production and public contract contain no formula search ownership.</summary>
    [Fact]
    public void ProductionAndPublicContractContainNoFormulaSearchOwnership()
    {
        var forbidden = new[]
        {
            "MathBlockProgramPopulation",
            "PopulationSearch",
            "EvolutionPolicy",
            "RandomImmigrant",
            "QualityDiversity",
            "ParetoArchive",
            "SearchCheckpoint",
            "SearchCursor",
            "ObjectivePolicy"
        };
        var assembly = typeof(MathBlockCatalog).Assembly;
        var publicNames = assembly.ExportedTypes
            .SelectMany(type => type.GetMembers(BindingFlags.Public | BindingFlags.Instance | BindingFlags.Static)
                .Select(member => $"{type.FullName}.{member.Name}")
                .Prepend(type.FullName ?? type.Name))
            .ToArray();
        var failures = new List<string>();
        foreach (var name in publicNames)
            foreach (var token in forbidden)
                if (name.Contains(token, StringComparison.Ordinal))
                    failures.Add(name);

        var root = FindRepositoryRoot();
        var sourceRoot = Path.Combine(root, "Supprocom.MathBlocks");
        foreach (var file in Directory.EnumerateFiles(sourceRoot, "*.cs", SearchOption.AllDirectories))
        {
            if (IsBuildOutput(sourceRoot, file) || file.EndsWith(".Tests.cs", StringComparison.Ordinal))
                continue;
            var source = File.ReadAllText(file);
            foreach (var token in forbidden)
                if (source.Contains(token, StringComparison.Ordinal))
                    failures.Add($"{Path.GetRelativePath(sourceRoot, file)}: {token}");
        }

        Assert.DoesNotContain(
            assembly.GetCustomAttributesData(),
            attribute => string.Equals(attribute.AttributeType.FullName, "System.Runtime.CompilerServices.InternalsVisibleToAttribute", StringComparison.Ordinal));
        Assert.Empty(failures);
    }

    /// <summary>Verifies external consumer uses only the packed public package.</summary>
    [Fact]
    public void ExternalConsumerUsesOnlyThePackedPublicPackage()
    {
        var root = FindRepositoryRoot();
        var projectPath = Path.Combine(
            root,
            "Supprocom.MathBlocks.ExternalConsumer",
            "Supprocom.MathBlocks.ExternalConsumer.csproj");
        var sourcePath = Path.Combine(root, "Supprocom.MathBlocks.ExternalConsumer", "Program.cs");
        var document = XDocument.Load(projectPath);
        var source = File.ReadAllText(sourcePath);

        Assert.Empty(document.Descendants("ProjectReference"));
        var package = Assert.Single(document.Descendants("PackageReference"));
        Assert.Equal("Supprocom.MathBlocks", package.Attribute("Include")!.Value);
        Assert.DoesNotContain("System.Reflection", source, StringComparison.Ordinal);
        Assert.DoesNotContain("InternalsVisibleTo", source, StringComparison.Ordinal);
        Assert.DoesNotContain("MathBlocksCUDAProgram", source, StringComparison.Ordinal);
        Assert.Contains("--formula-smoke", source, StringComparison.Ordinal);
        Assert.Contains("MathBlockFormulaInterchange.Profile", source, StringComparison.Ordinal);
    }

    /// <summary>Verifies public tree uses only cudaaccelerator identity.</summary>
    [Fact]
    public void PublicTreeUsesOnlyCUDAAcceleratorIdentity()
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
            Path.Combine(root, "Supprocom.MathBlocks.Tests"),
            Path.Combine(root, "Supprocom.MathBlocks.ExternalConsumer")
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

    /// <summary>Verifies production source contains no input or factor semantics.</summary>
    [Fact]
    public void ProductionSourceContainsNoInputOrFactorSemantics()
    {
        var root = FindRepositoryRoot();
        var sourceRoot = Path.Combine(root, "Supprocom.MathBlocks");
        var failures = new List<string>();
        foreach (var file in Directory.EnumerateFiles(sourceRoot, "*.cs", SearchOption.AllDirectories))
        {
            if (IsBuildOutput(sourceRoot, file))
                continue;
            var text = File.ReadAllText(file);
            var relative = Path.GetRelativePath(sourceRoot, file);
            foreach (Match match in ForbiddenSemanticWord().Matches(text))
                failures.Add($"{Path.GetFileName(file)}: {match.Value}");
            var isNativeInfrastructure = relative.StartsWith($"Cuda{Path.DirectorySeparatorChar}", StringComparison.Ordinal) ||
string.Equals(relative, Path.Combine("Execution", "MathBlocksCUDAWorker.cs"), StringComparison.Ordinal) ||
string.Equals(relative, Path.Combine("Execution", "MathBlocksCUDAProgram.cs"), StringComparison.Ordinal);
            if (!isNativeInfrastructure)
                foreach (Match match in ForbiddenEffectWord().Matches(text))
                {
                    if (relative.StartsWith(
                            $"Notation{Path.DirectorySeparatorChar}",
                            StringComparison.Ordinal) &&
string.Equals(match.Value, "Task", StringComparison.Ordinal))
                    {
                        continue;
                    }
                    failures.Add($"{Path.GetFileName(file)}: {match.Value}");
                }
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures));
    }

    /// <summary>Verifies public contract exposes only mathblock and system types.</summary>
    [Fact]
    public void PublicContractExposesOnlyMathblockAndSystemTypes()
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

    /// <summary>Verifies production math calls resolve to owned low level primitives.</summary>
    [Fact]
    public void ProductionMathCallsResolveToOwnedLowLevelPrimitives()
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
            if (SystemMathReference().IsMatch(source))
                systemMathReferences.Add(Path.GetRelativePath(sourceRoot, file));
        }

        Assert.Contains(
            "global using Math = Supprocom.MathBlocks.MathBlockPrimitives;",
            alias,
            StringComparison.Ordinal);
        Assert.Empty(systemMathReferences);
    }

    /// <summary>Verifies production binary has no system math member reference.</summary>
    [Fact]
    public void ProductionBinaryHasNoSystemMathMemberReference()
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
            if (string.Equals(metadata.GetString(type.Namespace), "System", StringComparison.Ordinal) && string.Equals(metadata.GetString(type.Name), "Math", StringComparison.Ordinal))
                references.Add(metadata.GetString(member.Name));
        }

        Assert.Empty(references);
    }

    /// <summary>Verifies production binary has no system linq enumerable member reference.</summary>
    [Fact]
    public void ProductionBinaryHasNoSystemLinqEnumerableMemberReference()
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
            if (string.Equals(metadata.GetString(type.Namespace), "System.Linq", StringComparison.Ordinal) &&
string.Equals(metadata.GetString(type.Name), "Enumerable", StringComparison.Ordinal))
            {
                references.Add(metadata.GetString(member.Name));
            }
        }

        Assert.Empty(references);
    }

    /// <summary>Verifies production source has no library collection algorithms.</summary>
    [Fact]
    public void ProductionSourceHasNoLibraryCollectionAlgorithms()
    {
        var root = FindRepositoryRoot();
        var sourceRoot = Path.Combine(root, "Supprocom.MathBlocks");
        var forbidden = new[]
        {
            "Array.Sort(",
            "Array.Copy(",
            "Array.Clear(",
            "Array.Fill(",
            "System.Numerics.BitOperations"
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

    /// <summary>Verifies production binary has no system numerics type reference.</summary>
    [Fact]
    public void ProductionBinaryHasNoSystemNumericsTypeReference()
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

    private static void AssertReadmeUsesOneParagraphAndOneSupplementPerSection(
        string source)
    {
        Assert.Empty(GetReadmeStructureErrors(source));
    }

    private static List<string> GetReadmeStructureErrors(string source)
    {
        var errors = new List<string>();
        var document = Markdown.Parse(source, ReadmePipeline);
        var section = "document preamble";
        var paragraphCount = 0;
        var supplementCount = 0;

        void FinishSection()
        {
            if (paragraphCount > 1)
                errors.Add($"README section '{section}' contains {paragraphCount} prose paragraphs.");
            if (supplementCount > 1)
                errors.Add($"README section '{section}' contains {supplementCount} code, table, or graph supplements.");
            paragraphCount = 0;
            supplementCount = 0;
        }

        foreach (var block in document)
        {
            if (block is HeadingBlock heading)
            {
                FinishSection();
                if (heading.Level > 2)
                    errors.Add($"README heading at line {heading.Line + 1} is deeper than level two.");
                section = $"heading at line {heading.Line + 1}";
                continue;
            }

            switch (block)
            {
                case ParagraphBlock:
                    paragraphCount++;
                    break;
                case CodeBlock:
                case Table:
                    supplementCount++;
                    break;
                case ListBlock:
                    errors.Add($"README section '{section}' contains a list.");
                    break;
                default:
                    errors.Add(
                        $"README section '{section}' contains unsupported CommonMark block '{block.GetType().Name}'.");
                    break;
            }
        }
        FinishSection();
        return errors;
    }

    private static void AssertPackageReadmeUsesImmutableLinks(string source)
    {
        Assert.Empty(GetPackageReadmeLinkErrors(source));
    }

    private static List<string> GetPackageReadmeLinkErrors(string source)
    {
        var errors = new List<string>();
        var links = Markdown.Parse(source, ReadmePipeline)
            .Descendants<LinkInline>()
            .Where(link => !link.IsImage)
            .ToArray();
        if (links.Length == 0)
            errors.Add("The package README contains no documentation links.");
        foreach (var link in links)
        {
            var target = link.Url ?? string.Empty;
            if (!Uri.TryCreate(target, UriKind.Absolute, out var uri) ||
!string.Equals(uri.Scheme, Uri.UriSchemeHttps, StringComparison.Ordinal) ||
!string.Equals(uri.Host, "github.com", StringComparison.Ordinal))
            {
                errors.Add($"Package README link '{target}' is not an absolute GitHub HTTPS URL.");
                continue;
            }

            var match = PackageReadmeLink().Match(uri.AbsolutePath);
            if (!match.Success)
                errors.Add($"Package README link '{target}' is not pinned to an immutable project document.");
        }
        return errors;
    }

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

    [GeneratedRegex(@"\b(?:Factor|Market|Price|Volume|Volatility|Trade|Trading|Bet|Betting|Candle|Timestamp|Binance|Polymarket)\b", RegexOptions.IgnoreCase, 1000)]
    private static partial Regex ForbiddenSemanticWord();

    [GeneratedRegex(@"\b(?:DateTime|DateTimeOffset|Random|Guid|Environment|File|Directory|HttpClient|Thread|Task|Process)\b", RegexOptions.None, 1000)]
    private static partial Regex ForbiddenEffectWord();

    [GeneratedRegex(@"\bSystem\.Math\b", RegexOptions.CultureInvariant, 1000)]
    private static partial Regex SystemMathReference();

    [GeneratedRegex(@"^/Supprocom/MathBlocks/blob/(?<commit>[0-9a-f]{40})/(?<path>(?:docs/[a-z0-9-]+\.md|LICENSE(?:\.md)?|NOTICE|THIRD-PARTY-NOTICES\.md))$", RegexOptions.CultureInvariant, 1000)]
    private static partial Regex PackageReadmeLink();
}
