namespace Supprocom.MathBlocks.Tests;

public sealed class VectorMedianV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.median@1");
}
