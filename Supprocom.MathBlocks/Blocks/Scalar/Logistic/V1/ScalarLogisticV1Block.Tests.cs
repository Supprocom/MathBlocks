namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarLogisticV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.logistic@1");
}
