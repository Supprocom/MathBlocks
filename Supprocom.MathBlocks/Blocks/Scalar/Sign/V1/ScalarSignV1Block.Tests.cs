namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarSignV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.sign@1");
}
