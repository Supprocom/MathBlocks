namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.inverse-hyperbolic-sine@1</c> operation contract.</summary>
public sealed class ScalarInverseHyperbolicSineV1BlockTests
{
    /// <summary>Checks the <c>scalar.inverse-hyperbolic-sine@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.inverse-hyperbolic-sine@1");
}
