namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>information.gini-impurity@1</c> operation contract.</summary>
public sealed class InformationGiniImpurityV1BlockTests
{
    /// <summary>Checks the <c>information.gini-impurity@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("information.gini-impurity@1");
}
