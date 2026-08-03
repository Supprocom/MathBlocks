namespace Supprocom.MathBlocks.Tests;

public sealed class MarkovEntropyProductionV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("markov.entropy-production@1");
}
