namespace Supprocom.MathBlocks.Tests;

public sealed class PathHysteresisV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("path.hysteresis@1");
}
