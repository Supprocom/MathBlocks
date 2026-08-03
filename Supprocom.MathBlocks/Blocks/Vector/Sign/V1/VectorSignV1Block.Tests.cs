namespace Supprocom.MathBlocks.Tests;

public sealed class VectorSignV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.sign@1");
}
