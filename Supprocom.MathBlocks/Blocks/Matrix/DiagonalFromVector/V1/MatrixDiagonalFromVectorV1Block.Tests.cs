namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixDiagonalFromVectorV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.diagonal-from-vector@1");
}
