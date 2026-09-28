namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>transport.energy-distance@1</c> operation contract.</summary>
public sealed class TransportEnergyDistanceV1BlockTests
{
    /// <summary>Checks the <c>transport.energy-distance@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("transport.energy-distance@1");
}
