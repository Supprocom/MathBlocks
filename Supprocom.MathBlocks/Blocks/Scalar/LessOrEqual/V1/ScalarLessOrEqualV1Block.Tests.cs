namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarLessOrEqualV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.less-or-equal@1");
}
