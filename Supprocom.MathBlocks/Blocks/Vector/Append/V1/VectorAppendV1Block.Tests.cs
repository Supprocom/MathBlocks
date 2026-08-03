namespace Supprocom.MathBlocks.Tests;

public sealed class VectorAppendV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.append@1");
}
