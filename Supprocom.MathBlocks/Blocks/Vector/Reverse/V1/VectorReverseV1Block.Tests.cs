namespace Supprocom.MathBlocks.Tests;

public sealed class VectorReverseV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.reverse@1");
}
