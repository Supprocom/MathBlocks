namespace Supprocom.MathBlocks.Tests;

public sealed class SurvivalProductLimitV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("survival.product-limit@1");
}
