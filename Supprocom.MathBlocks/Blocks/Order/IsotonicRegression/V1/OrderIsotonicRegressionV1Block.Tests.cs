namespace Supprocom.MathBlocks.Tests;

public sealed class OrderIsotonicRegressionV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("order.isotonic-regression@1");
}
