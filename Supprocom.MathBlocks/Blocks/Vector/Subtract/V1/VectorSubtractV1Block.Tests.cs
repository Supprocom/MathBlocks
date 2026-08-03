namespace Supprocom.MathBlocks.Tests;

public sealed class VectorSubtractV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.subtract@1");
}
