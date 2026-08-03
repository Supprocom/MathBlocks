namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarInverseHyperbolicCosineV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.inverse-hyperbolic-cosine@1");
}
