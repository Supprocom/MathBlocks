using System.Reflection.Metadata;
using System.Reflection.PortableExecutable;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Checks the metadata of the built Supprocom.MathBlocks assembly, which needs no CUDA device.</summary>
public sealed class MathBlockShippedAssemblyTests
{
    private const string TranspilerNamespace = "Supprocom.CSharp2CUDA";

    /// <summary>Verifies the built library holds no type in Supprocom.CSharp2CUDA, so a consumer's attribute lookup stays unambiguous.</summary>
    // A consumer that runs the CSharp2CUDA Roslyn translator with this assembly among its references looks the package attributes up
    // by metadata name. A copy of CudaDevice, CudaReadOnly or TranspileToCUDA here, even an internal one, makes that lookup ambiguous
    // and the consumer's own [CudaDevice] methods lose their translation (CS2CUDA005).
    [Fact]
    public void TheBuiltLibraryDefinesNoTypeInTheCSharp2CudaNamespace()
    {
        var path = typeof(MathBlockCatalog).Assembly.Location;
        Assert.False(string.IsNullOrEmpty(path), "The library assembly has no file location.");
        Assert.True(File.Exists(path), $"The library assembly {path} does not exist.");

        using var stream = File.OpenRead(path);
        using var peReader = new PEReader(stream);
        var reader = peReader.GetMetadataReader();

        var offenders = new List<string>();
        foreach (var handle in reader.TypeDefinitions)
        {
            var type = reader.GetTypeDefinition(handle);
            var typeNamespace = reader.GetString(type.Namespace);
            // Nested types carry an empty namespace; their declaring type is checked on its own.
            if (typeNamespace.StartsWith(TranspilerNamespace, StringComparison.Ordinal))
                offenders.Add($"{typeNamespace}.{reader.GetString(type.Name)}");
        }

        Assert.True(
            offenders.Count == 0,
            $"{Path.GetFileName(path)} defines types in {TranspilerNamespace}: {string.Join(", ", offenders)}.");
        Assert.True(reader.TypeDefinitions.Count > 100, "The metadata scan did not see the library's types.");
    }
}
