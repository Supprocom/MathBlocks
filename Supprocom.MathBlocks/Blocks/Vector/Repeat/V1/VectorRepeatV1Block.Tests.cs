namespace Supprocom.MathBlocks.Tests;

public sealed class VectorRepeatV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.repeat@1");
}
