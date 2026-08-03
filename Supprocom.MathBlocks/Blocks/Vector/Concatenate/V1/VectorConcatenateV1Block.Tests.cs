namespace Supprocom.MathBlocks.Tests;

public sealed class VectorConcatenateV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.concatenate@1");
}
