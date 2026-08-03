namespace Supprocom.MathBlocks.Tests;

public sealed class BooleanVectorTrueCountV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("boolean-vector.true-count@1");
}
