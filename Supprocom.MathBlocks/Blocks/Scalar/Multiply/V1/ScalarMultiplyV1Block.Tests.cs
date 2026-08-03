namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarMultiplyV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.multiply@1");
}
