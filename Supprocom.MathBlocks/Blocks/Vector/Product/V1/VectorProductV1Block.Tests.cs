namespace Supprocom.MathBlocks.Tests;

public sealed class VectorProductV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.product@1");
}
