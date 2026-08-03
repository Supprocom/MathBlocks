namespace Supprocom.MathBlocks.Tests;

public sealed class TransportMonotoneCouplingV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("transport.monotone-coupling@1");
}
