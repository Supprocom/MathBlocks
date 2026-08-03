namespace Supprocom.MathBlocks.Tests;

public sealed class VectorGreaterThanV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.greater-than@1");
}
