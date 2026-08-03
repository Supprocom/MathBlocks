namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixPerronVectorV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.perron-vector@1");
}
