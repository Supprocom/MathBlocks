namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarBinaryLogarithmV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.binary-logarithm@1");
}
