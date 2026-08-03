namespace Supprocom.MathBlocks.Tests;

public sealed class VectorSortV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.sort@1");
}
