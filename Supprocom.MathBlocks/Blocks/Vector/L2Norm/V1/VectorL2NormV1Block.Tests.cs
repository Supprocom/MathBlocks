namespace Supprocom.MathBlocks.Tests;

public sealed class VectorL2NormV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.l2-norm@1");
}
