namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>polynomial.evaluate@1</c> operation contract.</summary>
public sealed class PolynomialEvaluateV1BlockTests
{
    /// <summary>Checks the <c>polynomial.evaluate@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("polynomial.evaluate@1");
}
