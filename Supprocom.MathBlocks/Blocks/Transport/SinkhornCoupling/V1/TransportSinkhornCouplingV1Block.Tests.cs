namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>transport.sinkhorn-coupling@1</c> operation contract.</summary>
public sealed class TransportSinkhornCouplingV1BlockTests
{
    /// <summary>Checks the <c>transport.sinkhorn-coupling@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("transport.sinkhorn-coupling@1");
}
