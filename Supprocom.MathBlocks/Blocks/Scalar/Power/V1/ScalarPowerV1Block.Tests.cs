namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.power@1</c> operation contract.</summary>
public sealed class ScalarPowerV1BlockTests
{
    /// <summary>Checks the <c>scalar.power@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.power@1");
}
