namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarPowerV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.power@1");
}
