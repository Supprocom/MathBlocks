namespace Supprocom.MathBlocks.Tests;

public sealed class VectorStandardizeV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.standardize@1");
}
