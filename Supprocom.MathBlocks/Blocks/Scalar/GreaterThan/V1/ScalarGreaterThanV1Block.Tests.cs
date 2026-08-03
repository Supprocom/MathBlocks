namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarGreaterThanV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.greater-than@1");
}
