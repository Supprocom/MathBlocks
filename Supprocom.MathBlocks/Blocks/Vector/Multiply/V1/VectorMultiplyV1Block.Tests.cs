namespace Supprocom.MathBlocks.Tests;

public sealed class VectorMultiplyV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.multiply@1");
}
