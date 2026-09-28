namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>polynomial.bernstein-evaluate@1</c> operation contract.</summary>
public sealed class PolynomialBernsteinEvaluateV1BlockTests
{
    /// <summary>Checks the <c>polynomial.bernstein-evaluate@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("polynomial.bernstein-evaluate@1");
}
