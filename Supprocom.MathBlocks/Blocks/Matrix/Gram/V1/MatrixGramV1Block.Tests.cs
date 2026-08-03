namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixGramV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.gram@1");
}
