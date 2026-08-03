namespace Supprocom.MathBlocks.Tests;

public sealed class ComplexMatrixPickV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("complex-matrix.pick@1");
}
