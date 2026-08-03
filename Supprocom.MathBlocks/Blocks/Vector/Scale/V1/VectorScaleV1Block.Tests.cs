namespace Supprocom.MathBlocks.Tests;

public sealed class VectorScaleV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.scale@1");
}
