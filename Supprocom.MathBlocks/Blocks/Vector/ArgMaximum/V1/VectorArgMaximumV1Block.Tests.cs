namespace Supprocom.MathBlocks.Tests;

public sealed class VectorArgMaximumV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.arg-maximum@1");
}
