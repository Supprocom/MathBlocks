namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>polynomial.derivative@1</c> operation contract.</summary>
public sealed class PolynomialDerivativeV1BlockTests
{
    /// <summary>Checks the <c>polynomial.derivative@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("polynomial.derivative@1");
}
