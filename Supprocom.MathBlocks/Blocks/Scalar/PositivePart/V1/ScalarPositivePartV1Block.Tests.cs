namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarPositivePartV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.positive-part@1");
}
