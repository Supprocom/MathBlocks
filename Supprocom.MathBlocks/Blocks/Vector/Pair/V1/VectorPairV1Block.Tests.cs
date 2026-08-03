namespace Supprocom.MathBlocks.Tests;

public sealed class VectorPairV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.pair@1");
}
