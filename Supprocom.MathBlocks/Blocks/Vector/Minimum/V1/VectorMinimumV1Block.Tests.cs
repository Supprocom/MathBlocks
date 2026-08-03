namespace Supprocom.MathBlocks.Tests;

public sealed class VectorMinimumV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.minimum@1");
}
