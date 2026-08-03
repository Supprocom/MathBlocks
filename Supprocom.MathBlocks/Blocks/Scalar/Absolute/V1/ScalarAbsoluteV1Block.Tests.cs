namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarAbsoluteV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.absolute@1");
}
