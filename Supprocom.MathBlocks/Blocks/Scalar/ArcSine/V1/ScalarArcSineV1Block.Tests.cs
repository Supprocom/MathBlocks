namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarArcSineV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.arc-sine@1");
}
