namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixSmallestSymmetricEigenvalueV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.smallest-symmetric-eigenvalue@1");
}
