namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixSubtractV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.subtract@1");
}
