namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarLogOnePlusV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.log-one-plus@1");
}
