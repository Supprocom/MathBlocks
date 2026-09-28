namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>state.transition-counts@1</c> operation contract.</summary>
public sealed class StateTransitionCountsV1BlockTests
{
    /// <summary>Checks the <c>state.transition-counts@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("state.transition-counts@1");
}
