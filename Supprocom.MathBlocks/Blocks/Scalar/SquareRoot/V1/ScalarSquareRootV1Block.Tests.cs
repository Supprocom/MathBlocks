namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarSquareRootV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.square-root@1");
}
