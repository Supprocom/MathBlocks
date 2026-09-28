namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>transport.coupling-cost@1</c> operation contract.</summary>
public sealed class TransportCouplingCostV1BlockTests
{
    /// <summary>Checks the <c>transport.coupling-cost@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("transport.coupling-cost@1");
}
