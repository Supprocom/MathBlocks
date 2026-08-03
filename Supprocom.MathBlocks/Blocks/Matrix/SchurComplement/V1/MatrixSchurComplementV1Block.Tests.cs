namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixSchurComplementV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.schur-complement@1");
}
