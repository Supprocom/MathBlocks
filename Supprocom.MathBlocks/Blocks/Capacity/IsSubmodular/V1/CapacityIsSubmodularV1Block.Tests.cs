namespace Supprocom.MathBlocks.Tests;

public sealed class CapacityIsSubmodularV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("capacity.is-submodular@1");
}
