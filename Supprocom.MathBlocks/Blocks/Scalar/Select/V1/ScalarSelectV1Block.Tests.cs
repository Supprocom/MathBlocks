namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarSelectV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.select@1");
}
