namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>cooperative.shapley-values@1</c> operation contract.</summary>
public sealed class CooperativeShapleyValuesV1BlockTests
{
    /// <summary>Checks the <c>cooperative.shapley-values@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("cooperative.shapley-values@1");
}
