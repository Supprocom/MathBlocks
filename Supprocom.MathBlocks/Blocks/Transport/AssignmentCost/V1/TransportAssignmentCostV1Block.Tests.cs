namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>transport.assignment-cost@1</c> operation contract.</summary>
public sealed class TransportAssignmentCostV1BlockTests
{
    /// <summary>Checks the <c>transport.assignment-cost@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("transport.assignment-cost@1");
}
