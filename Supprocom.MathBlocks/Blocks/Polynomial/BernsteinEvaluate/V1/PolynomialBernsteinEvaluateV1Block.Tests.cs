namespace Supprocom.MathBlocks.Tests;

public sealed class PolynomialBernsteinEvaluateV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("polynomial.bernstein-evaluate@1");
}
