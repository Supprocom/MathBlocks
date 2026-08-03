namespace Supprocom.MathBlocks.Tests;

public sealed class VectorSumV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.sum@1");
}
