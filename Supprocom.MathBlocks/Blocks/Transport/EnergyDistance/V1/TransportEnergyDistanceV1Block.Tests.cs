namespace Supprocom.MathBlocks.Tests;

public sealed class TransportEnergyDistanceV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("transport.energy-distance@1");
}
