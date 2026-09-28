namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>transform.walsh-hadamard@1</c> operation contract.</summary>
public sealed class TransformWalshHadamardV1BlockTests
{
    /// <summary>Checks the <c>transform.walsh-hadamard@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("transform.walsh-hadamard@1");
}
