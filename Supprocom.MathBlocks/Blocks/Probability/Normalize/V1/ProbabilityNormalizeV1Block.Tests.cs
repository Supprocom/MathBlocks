namespace Supprocom.MathBlocks.Tests;

public sealed class ProbabilityNormalizeV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("probability.normalize@1");
}
