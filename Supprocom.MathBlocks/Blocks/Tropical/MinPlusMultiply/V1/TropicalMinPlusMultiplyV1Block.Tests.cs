namespace Supprocom.MathBlocks.Tests;

public sealed class TropicalMinPlusMultiplyV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("tropical.min-plus-multiply@1");
}
