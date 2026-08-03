namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixPerronValueV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.perron-value@1");
}
