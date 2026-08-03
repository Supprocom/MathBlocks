namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarCosineV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.cosine@1");
}
