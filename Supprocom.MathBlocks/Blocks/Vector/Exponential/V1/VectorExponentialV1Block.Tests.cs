namespace Supprocom.MathBlocks.Tests;

public sealed class VectorExponentialV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.exponential@1");
}
