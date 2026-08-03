namespace Supprocom.MathBlocks.Tests;

public sealed class TransportCouplingCostV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("transport.coupling-cost@1");
}
