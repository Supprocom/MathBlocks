namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarHyperbolicSineV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.hyperbolic-sine@1");
}
