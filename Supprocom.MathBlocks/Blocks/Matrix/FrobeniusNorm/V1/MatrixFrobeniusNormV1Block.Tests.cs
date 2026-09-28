namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.frobenius-norm@1</c> operation contract.</summary>
public sealed class MatrixFrobeniusNormV1BlockTests
{
    /// <summary>Checks the <c>matrix.frobenius-norm@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.frobenius-norm@1");
}
