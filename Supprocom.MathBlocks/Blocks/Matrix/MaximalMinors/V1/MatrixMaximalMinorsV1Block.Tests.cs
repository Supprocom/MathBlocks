namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixMaximalMinorsV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.maximal-minors@1");
}
