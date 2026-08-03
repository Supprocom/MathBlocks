namespace Supprocom.MathBlocks.Tests;

public sealed class CapacityMobiusTransformV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("capacity.mobius-transform@1");
}
