namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarCommonLogarithmV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.common-logarithm@1");
}
