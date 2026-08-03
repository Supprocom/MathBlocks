namespace Supprocom.MathBlocks.Tests;

public sealed class CapacityChoquetIntegralV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("capacity.choquet-integral@1");
}
