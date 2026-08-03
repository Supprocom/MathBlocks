namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixRankV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.rank@1");
}
