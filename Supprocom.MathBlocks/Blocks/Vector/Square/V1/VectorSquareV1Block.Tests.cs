namespace Supprocom.MathBlocks.Tests;

public sealed class VectorSquareV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.square@1");
}
