namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixOuterProductV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.outer-product@1");
}
