namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixRowSumsV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.row-sums@1");
}
