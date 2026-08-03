namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarClampV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.clamp@1");
}
