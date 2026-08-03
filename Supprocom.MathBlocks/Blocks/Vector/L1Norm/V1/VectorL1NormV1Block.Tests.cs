namespace Supprocom.MathBlocks.Tests;

public sealed class VectorL1NormV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.l1-norm@1");
}
