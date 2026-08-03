namespace Supprocom.MathBlocks.Tests;

public sealed class InformationGiniImpurityV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("information.gini-impurity@1");
}
