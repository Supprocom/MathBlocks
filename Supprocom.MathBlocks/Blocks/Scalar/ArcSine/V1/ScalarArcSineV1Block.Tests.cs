namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.arc-sine@1</c> operation contract.</summary>
public sealed class ScalarArcSineV1BlockTests
{
    /// <summary>Checks the <c>scalar.arc-sine@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.arc-sine@1");
}
