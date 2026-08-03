namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarNegateV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.negate@1");
}
