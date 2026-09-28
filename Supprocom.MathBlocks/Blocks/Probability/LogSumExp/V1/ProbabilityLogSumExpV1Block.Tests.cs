namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>probability.log-sum-exp@1</c> operation contract.</summary>
public sealed class ProbabilityLogSumExpV1BlockTests
{
    /// <summary>Checks the <c>probability.log-sum-exp@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("probability.log-sum-exp@1");
}
