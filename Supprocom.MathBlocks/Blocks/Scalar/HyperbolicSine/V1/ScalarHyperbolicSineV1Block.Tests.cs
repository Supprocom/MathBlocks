namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.hyperbolic-sine@1</c> operation contract.</summary>
public sealed class ScalarHyperbolicSineV1BlockTests
{
    /// <summary>Checks the <c>scalar.hyperbolic-sine@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.hyperbolic-sine@1");
}
