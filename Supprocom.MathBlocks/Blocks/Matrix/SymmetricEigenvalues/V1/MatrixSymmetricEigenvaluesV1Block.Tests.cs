namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixSymmetricEigenvaluesV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.symmetric-eigenvalues@1");
}
