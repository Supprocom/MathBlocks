namespace Supprocom.MathBlocks.Tests;

public sealed class VectorDotV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.dot@1");
}
