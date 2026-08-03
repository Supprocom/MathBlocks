namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixLargestSymmetricEigenvalueV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.largest-symmetric-eigenvalue@1");
}
