using Supprocom.MathBlocks.Cuda;
using System.Runtime.CompilerServices;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Contains regression tests for Math Block Feature Folder Tests.</summary>
public sealed class MathBlockFeatureFolderTests
{
    /// <summary>Verifies every block owns one definition cpucudaand test file.</summary>
    [Fact]
    public void EveryBlockOwnsOneDefinitionCPUCUDAAndTestFile()
    {
        var root = FindRepositoryRoot();
        var blocksRoot = Path.Combine(root, "Supprocom.MathBlocks", "Blocks");
        var definitions = Directory.GetFiles(blocksRoot, "*.Definition.cs", SearchOption.AllDirectories);
        var cpuImplementations = Directory.GetFiles(blocksRoot, "*.Cpu.cs", SearchOption.AllDirectories);
        var cudaBindings = Directory.GetFiles(blocksRoot, "*.Cuda.cs", SearchOption.AllDirectories);
        var tests = Directory.GetFiles(blocksRoot, "*.Tests.cs", SearchOption.AllDirectories);
        var registered = MathBlockCatalog.Standard.Operations
            .Select(operation => operation.Identity)
            .ToHashSet(StringComparer.Ordinal);

        Assert.Equal(registered.Count, definitions.Length);
        Assert.Equal(registered.Count, cpuImplementations.Length);
        Assert.Equal(registered.Count, cudaBindings.Length);
        Assert.Equal(registered.Count, tests.Length);
        foreach (var definition in definitions)
        {
            var directory = Path.GetDirectoryName(definition)!;
            var stem = Path.GetFileName(definition).Replace(".Definition.cs", string.Empty, StringComparison.Ordinal);
            var definitionSource = File.ReadAllText(definition);
            var identity = ReadIdentity(definitionSource);

            Assert.Contains(identity, registered);
            Assert.Contains("MathBlockOperation Create()", definitionSource, StringComparison.Ordinal);
            var cpuPath = Path.Combine(directory, $"{stem}.Cpu.cs");
            Assert.True(File.Exists(cpuPath), $"{identity} has no CPU implementation file.");
            Assert.Contains("static", File.ReadAllText(cpuPath), StringComparison.Ordinal);
            var cudaPath = Path.Combine(directory, $"{stem}.Cuda.cs");
            Assert.True(File.Exists(cudaPath), $"{identity} has no CUDA implementation file.");
            Assert.Contains("MathBlockCudaFeature Feature", File.ReadAllText(cudaPath), StringComparison.Ordinal);
            Assert.True(File.Exists(Path.Combine(directory, $"{stem}.Tests.cs")), $"{identity} has no test file.");
        }

        Assert.Equal(
            registered.Order(StringComparer.Ordinal),
            MathBlocksCUDAWorker.SupportedBlockIdentities.Order(StringComparer.Ordinal));
    }

    /// <summary>Verifies grouped registries and cudaidentity tables are absent.</summary>
    [Fact]
    public void GroupedRegistriesAndCUDAIdentityTablesAreAbsent()
    {
        var root = FindRepositoryRoot();
        var cpuRoot = Path.Combine(root, "Supprocom.MathBlocks");
        foreach (var path in Directory.GetFiles(cpuRoot, "*.cs", SearchOption.TopDirectoryOnly))
            Assert.DoesNotContain("void Register(", File.ReadAllText(path), StringComparison.Ordinal);

        var cudaRoot = Path.Combine(root, "MathBlocks.CudaSourceGenerator", "TranslationUnits");
        foreach (var path in Directory.GetFiles(cudaRoot, "*Module.cs", SearchOption.TopDirectoryOnly))
        {
            var source = File.ReadAllText(path);
            Assert.DoesNotContain("CreateOpcodes", source, StringComparison.Ordinal);
            Assert.DoesNotContain("SupportedIdentities", source, StringComparison.Ordinal);
            Assert.DoesNotContain("GetOpcode", source, StringComparison.Ordinal);
        }
    }

    /// <summary>Verifies cpuand cudaworkers are in one production assembly.</summary>
    [Fact]
    public void CPUAndCUDAWorkersAreInOneProductionAssembly()
    {
        var root = FindRepositoryRoot();

        Assert.Same(typeof(MathBlockCatalog).Assembly, typeof(MathBlocksCUDAWorker).Assembly);
        Assert.False(Directory.Exists(Path.Combine(root, "Supprocom.MathBlocks.Cuda")));
    }

    private static string ReadIdentity(string source)
    {
        const string prefix = "internal const string Identity = \"";
        var start = source.IndexOf(prefix, StringComparison.Ordinal);
        Assert.True(start >= 0, "The block definition has no identity.");
        start += prefix.Length;
        var end = source.IndexOf('"', start);
        Assert.True(end > start, "The block identity is empty.");
        return source[start..end];
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
                {
                    return directory.FullName;
                }
                directory = directory.Parent;
            }
        }
        throw new DirectoryNotFoundException("The repository root was not found.");
    }
}
