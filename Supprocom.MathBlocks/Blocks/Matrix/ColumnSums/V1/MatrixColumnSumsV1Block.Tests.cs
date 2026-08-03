namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixColumnSumsV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.column-sums@1");
}
