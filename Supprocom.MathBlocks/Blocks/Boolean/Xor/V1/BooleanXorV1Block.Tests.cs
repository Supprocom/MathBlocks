namespace Supprocom.MathBlocks.Tests;

public sealed class BooleanXorV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("boolean.xor@1");
}
