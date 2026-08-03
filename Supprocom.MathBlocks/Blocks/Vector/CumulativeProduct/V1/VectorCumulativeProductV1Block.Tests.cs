namespace Supprocom.MathBlocks.Tests;

public sealed class VectorCumulativeProductV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.cumulative-product@1");
}
