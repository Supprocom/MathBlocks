namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarSquareV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.square@1");
}
