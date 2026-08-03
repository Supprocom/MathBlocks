namespace Supprocom.MathBlocks.Tests;

public sealed class SurvivalDiscreteHazardV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("survival.discrete-hazard@1");
}
