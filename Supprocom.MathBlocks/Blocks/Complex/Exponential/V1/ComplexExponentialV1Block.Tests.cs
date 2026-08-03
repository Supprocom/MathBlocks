namespace Supprocom.MathBlocks.Tests;

public sealed class ComplexExponentialV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("complex.exponential@1");
}
