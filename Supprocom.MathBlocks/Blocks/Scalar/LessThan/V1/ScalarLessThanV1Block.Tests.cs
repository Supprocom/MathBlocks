namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarLessThanV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.less-than@1");
}
