namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarFloorV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.floor@1");
}
