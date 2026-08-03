namespace Supprocom.MathBlocks.Tests;

public sealed class PolynomialEvaluateV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("polynomial.evaluate@1");
}
