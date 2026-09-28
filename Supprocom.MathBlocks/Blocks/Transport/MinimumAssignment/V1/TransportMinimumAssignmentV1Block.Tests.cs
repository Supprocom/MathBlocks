namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>transport.minimum-assignment@1</c> operation contract.</summary>
public sealed class TransportMinimumAssignmentV1BlockTests
{
    /// <summary>Checks the <c>transport.minimum-assignment@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("transport.minimum-assignment@1");
}
