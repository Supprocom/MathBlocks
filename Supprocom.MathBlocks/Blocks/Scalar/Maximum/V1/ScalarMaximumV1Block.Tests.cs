namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarMaximumV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.maximum@1");
}
