namespace Supprocom.MathBlocks.Tests;

public sealed class TransportSinkhornCouplingV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("transport.sinkhorn-coupling@1");
}
