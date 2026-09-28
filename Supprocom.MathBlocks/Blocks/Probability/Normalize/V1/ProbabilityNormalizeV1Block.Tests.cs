namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>probability.normalize@1</c> operation contract.</summary>
public sealed class ProbabilityNormalizeV1BlockTests
{
    /// <summary>Checks the <c>probability.normalize@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("probability.normalize@1");
}
