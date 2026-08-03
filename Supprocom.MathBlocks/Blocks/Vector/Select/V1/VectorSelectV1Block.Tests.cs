namespace Supprocom.MathBlocks.Tests;

public sealed class VectorSelectV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.select@1");
}
