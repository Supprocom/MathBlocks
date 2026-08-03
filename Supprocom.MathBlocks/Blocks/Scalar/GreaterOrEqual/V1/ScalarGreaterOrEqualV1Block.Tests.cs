namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarGreaterOrEqualV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.greater-or-equal@1");
}
