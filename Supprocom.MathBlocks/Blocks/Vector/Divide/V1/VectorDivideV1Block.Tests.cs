namespace Supprocom.MathBlocks.Tests;

public sealed class VectorDivideV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.divide@1");
}
