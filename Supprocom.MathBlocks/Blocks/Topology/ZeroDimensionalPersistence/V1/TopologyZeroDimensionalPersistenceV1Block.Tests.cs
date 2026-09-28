namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>topology.zero-dimensional-persistence@1</c> operation contract.</summary>
public sealed class TopologyZeroDimensionalPersistenceV1BlockTests
{
    /// <summary>Checks the <c>topology.zero-dimensional-persistence@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("topology.zero-dimensional-persistence@1");
}
