namespace Supprocom.MathBlocks.Tests;

public sealed class VectorCumulativeSumV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.cumulative-sum@1");
}
