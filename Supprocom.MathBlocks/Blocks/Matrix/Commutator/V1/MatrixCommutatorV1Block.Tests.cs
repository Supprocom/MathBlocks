namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixCommutatorV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.commutator@1");
}
