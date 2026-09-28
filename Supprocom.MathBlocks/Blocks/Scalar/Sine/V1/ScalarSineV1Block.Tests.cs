namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.sine@1</c> operation contract.</summary>
public sealed class ScalarSineV1BlockTests
{
    /// <summary>Checks the <c>scalar.sine@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.sine@1");
}
