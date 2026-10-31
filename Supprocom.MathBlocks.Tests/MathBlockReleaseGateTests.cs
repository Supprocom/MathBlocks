using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the release requirement that every catalog operation has a CUDA implementation.</summary>
public sealed class MathBlockReleaseGateTests
{
    /// <summary>Checks that every Standard, window and elementwise operation is covered by the CUDA module.</summary>
    [Fact]
    [Trait("Category", "ReleaseGate")]
    public void EveryCatalogOperationHasACUDAImplementation()
    {
        var cudaIdentities = new HashSet<string>(
            MathBlockCudaDeviceModule.Operations.Select(contract => contract.Identity),
            StringComparer.Ordinal);
        var missing = MathBlockCatalog.Standard.Operations
            .Concat(MathBlockWindowTestSupport.Windowed.Operations)
            .Concat(MathBlockElementwiseTestSupport.Elementwise.Operations)
            .Select(operation => operation.Identity)
            .Where(identity => !cudaIdentities.Contains(identity))
            .Order(StringComparer.Ordinal)
            .ToArray();

        Assert.True(
            missing.Length == 0,
            $"{missing.Length} operations have no CUDA implementation: {string.Join(", ", missing)}");
    }
}
