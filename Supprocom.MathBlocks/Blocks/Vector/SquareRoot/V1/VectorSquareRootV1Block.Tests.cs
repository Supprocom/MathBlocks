namespace Supprocom.MathBlocks.Tests;

public sealed class VectorSquareRootV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.square-root@1");
}
