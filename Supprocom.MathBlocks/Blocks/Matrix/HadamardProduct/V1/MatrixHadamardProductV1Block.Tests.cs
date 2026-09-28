namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.hadamard-product@1</c> operation contract.</summary>
public sealed class MatrixHadamardProductV1BlockTests
{
    /// <summary>Checks the <c>matrix.hadamard-product@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.hadamard-product@1");
}
