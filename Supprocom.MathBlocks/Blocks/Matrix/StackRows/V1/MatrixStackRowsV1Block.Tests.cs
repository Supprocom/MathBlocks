namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixStackRowsV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.stack-rows@1");
}
