namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarHyperbolicTangentV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.hyperbolic-tangent@1");
}
