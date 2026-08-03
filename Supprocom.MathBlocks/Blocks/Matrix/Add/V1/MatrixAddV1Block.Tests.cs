namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixAddV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.add@1");
}
