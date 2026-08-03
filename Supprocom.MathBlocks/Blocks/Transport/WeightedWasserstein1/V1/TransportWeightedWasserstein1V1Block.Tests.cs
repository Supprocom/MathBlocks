namespace Supprocom.MathBlocks.Tests;

public sealed class TransportWeightedWasserstein1V1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("transport.weighted-wasserstein-1@1");
}
