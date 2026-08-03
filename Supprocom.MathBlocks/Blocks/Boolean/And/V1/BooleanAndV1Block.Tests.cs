namespace Supprocom.MathBlocks.Tests;

public sealed class BooleanAndV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("boolean.and@1");
}
