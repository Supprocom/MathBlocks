namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarHyperbolicCosineV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.hyperbolic-cosine@1");
}
