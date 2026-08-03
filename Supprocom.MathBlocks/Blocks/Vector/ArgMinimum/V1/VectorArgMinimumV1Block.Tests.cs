namespace Supprocom.MathBlocks.Tests;

public sealed class VectorArgMinimumV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.arg-minimum@1");
}
