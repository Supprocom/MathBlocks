namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarNaturalLogarithmV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.natural-logarithm@1");
}
