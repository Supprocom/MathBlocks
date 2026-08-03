using Supprocom.MathBlocks.Gpu;
using System.Runtime.CompilerServices;

namespace Supprocom.MathBlocks.Tests;

public sealed class MathBlockFeatureFolderTests
{
    [Fact]
    public void Every_block_owns_one_definition_CPU_GPU_and_test_file()
    {
        var root = FindRepositoryRoot();
        var blocksRoot = Path.Combine(root, "Supprocom.MathBlocks", "Blocks");
        var definitions = Directory.GetFiles(blocksRoot, "*.Definition.cs", SearchOption.AllDirectories);
        var cpuImplementations = Directory.GetFiles(blocksRoot, "*.Cpu.cs", SearchOption.AllDirectories);
        var gpuBindings = Directory.GetFiles(blocksRoot, "*.Gpu.cs", SearchOption.AllDirectories);
        var tests = Directory.GetFiles(blocksRoot, "*.Tests.cs", SearchOption.AllDirectories);
        var registered = MathBlockCatalog.Standard.Operations
            .Select(operation => operation.Identity)
            .ToHashSet(StringComparer.Ordinal);

        Assert.Equal(registered.Count, definitions.Length);
        Assert.Equal(registered.Count, cpuImplementations.Length);
        Assert.Equal(registered.Count, gpuBindings.Length);
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
            var gpuPath = Path.Combine(directory, $"{stem}.Gpu.cs");
            Assert.True(File.Exists(gpuPath), $"{identity} has no GPU implementation file.");
            Assert.Contains("MathBlockGpuFeature Feature", File.ReadAllText(gpuPath), StringComparison.Ordinal);
            Assert.True(File.Exists(Path.Combine(directory, $"{stem}.Tests.cs")), $"{identity} has no test file.");
        }

        Assert.Equal(
            registered.OrderBy(identity => identity, StringComparer.Ordinal),
            MathBlocksGPUWorker.SupportedBlockIdentities.OrderBy(identity => identity, StringComparer.Ordinal));
    }

    [Fact]
    public void Grouped_registries_and_GPU_identity_tables_are_absent()
    {
        var root = FindRepositoryRoot();
        var cpuRoot = Path.Combine(root, "Supprocom.MathBlocks");
        foreach (var path in Directory.GetFiles(cpuRoot, "*.cs", SearchOption.TopDirectoryOnly))
            Assert.DoesNotContain("void Register(", File.ReadAllText(path), StringComparison.Ordinal);

        var gpuRoot = Path.Combine(root, "Supprocom.MathBlocks", "Gpu", "Blocks");
        foreach (var path in Directory.GetFiles(gpuRoot, "*GpuBlockCatalog.cs", SearchOption.AllDirectories))
        {
            var source = File.ReadAllText(path);
            Assert.DoesNotContain("CreateOpcodes", source, StringComparison.Ordinal);
            Assert.DoesNotContain("SupportedIdentities", source, StringComparison.Ordinal);
            Assert.DoesNotContain("GetOpcode", source, StringComparison.Ordinal);
        }
    }

    [Fact]
    public void CPU_and_GPU_workers_are_in_one_production_assembly()
    {
        var root = FindRepositoryRoot();

        Assert.Same(typeof(MathBlockCatalog).Assembly, typeof(MathBlocksGPUWorker).Assembly);
        Assert.False(Directory.Exists(Path.Combine(root, "Supprocom.MathBlocks.Gpu")));
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
