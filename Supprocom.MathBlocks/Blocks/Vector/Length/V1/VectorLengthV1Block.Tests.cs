namespace Supprocom.MathBlocks.Tests;

public sealed class VectorLengthV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.length@1");
}
