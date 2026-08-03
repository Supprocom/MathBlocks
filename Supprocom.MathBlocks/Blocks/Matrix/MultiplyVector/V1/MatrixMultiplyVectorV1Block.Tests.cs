namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixMultiplyVectorV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.multiply-vector@1");
}
