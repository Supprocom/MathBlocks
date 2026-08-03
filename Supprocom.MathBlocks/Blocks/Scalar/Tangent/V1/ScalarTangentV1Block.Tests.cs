namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarTangentV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.tangent@1");
}
