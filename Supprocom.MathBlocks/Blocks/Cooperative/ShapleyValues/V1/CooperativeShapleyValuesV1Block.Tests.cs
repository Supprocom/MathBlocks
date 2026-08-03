namespace Supprocom.MathBlocks.Tests;

public sealed class CooperativeShapleyValuesV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("cooperative.shapley-values@1");
}
