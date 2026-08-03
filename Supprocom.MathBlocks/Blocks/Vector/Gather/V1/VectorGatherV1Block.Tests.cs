namespace Supprocom.MathBlocks.Tests;

public sealed class VectorGatherV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.gather@1");
}
