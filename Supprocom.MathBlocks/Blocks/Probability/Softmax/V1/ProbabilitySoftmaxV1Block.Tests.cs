namespace Supprocom.MathBlocks.Tests;

public sealed class ProbabilitySoftmaxV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("probability.softmax@1");
}
