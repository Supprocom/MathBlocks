namespace Supprocom.MathBlocks.Tests;

public sealed class InequalityGiniCoefficientV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("inequality.gini-coefficient@1");
}
