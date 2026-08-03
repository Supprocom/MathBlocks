namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixAppendRowV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.append-row@1");
}
