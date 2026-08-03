namespace Supprocom.MathBlocks.Tests;

public sealed class TropicalMaxPlusMultiplyV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("tropical.max-plus-multiply@1");
}
