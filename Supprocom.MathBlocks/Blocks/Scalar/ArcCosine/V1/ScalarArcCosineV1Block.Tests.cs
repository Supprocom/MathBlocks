namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarArcCosineV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.arc-cosine@1");
}
