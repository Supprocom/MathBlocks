namespace Supprocom.MathBlocks.Tests;

public sealed class TopologyZeroDimensionalPersistenceV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("topology.zero-dimensional-persistence@1");
}
