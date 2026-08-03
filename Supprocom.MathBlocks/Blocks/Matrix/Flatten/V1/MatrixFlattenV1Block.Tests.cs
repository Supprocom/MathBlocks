namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixFlattenV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.flatten@1");
}
