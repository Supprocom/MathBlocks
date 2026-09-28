namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>survival.discrete-hazard@1</c> operation contract.</summary>
public sealed class SurvivalDiscreteHazardV1BlockTests
{
    /// <summary>Checks the <c>survival.discrete-hazard@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("survival.discrete-hazard@1");
}
