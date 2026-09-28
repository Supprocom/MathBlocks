namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>transport.monotone-coupling@1</c> operation contract.</summary>
public sealed class TransportMonotoneCouplingV1BlockTests
{
    /// <summary>Checks the <c>transport.monotone-coupling@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("transport.monotone-coupling@1");
}
