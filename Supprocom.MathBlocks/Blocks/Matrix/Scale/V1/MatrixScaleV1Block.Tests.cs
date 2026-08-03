namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixScaleV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.scale@1");
}
