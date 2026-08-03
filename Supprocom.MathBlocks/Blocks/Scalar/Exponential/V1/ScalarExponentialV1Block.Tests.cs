namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarExponentialV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.exponential@1");
}
