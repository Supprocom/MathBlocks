namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>markov.entropy-production@1</c> operation contract.</summary>
public sealed class MarkovEntropyProductionV1BlockTests
{
    /// <summary>Checks the <c>markov.entropy-production@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("markov.entropy-production@1");
}
