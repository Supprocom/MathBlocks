namespace Supprocom.MathBlocks.Tests;

public sealed class VectorNormalizeL2V1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.normalize-l2@1");
}
