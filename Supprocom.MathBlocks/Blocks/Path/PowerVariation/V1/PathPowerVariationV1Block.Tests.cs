namespace Supprocom.MathBlocks.Tests;

public sealed class PathPowerVariationV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("path.power-variation@1");
}
