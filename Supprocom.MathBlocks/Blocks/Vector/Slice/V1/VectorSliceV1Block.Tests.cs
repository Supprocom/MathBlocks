namespace Supprocom.MathBlocks.Tests;

public sealed class VectorSliceV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.slice@1");
}
