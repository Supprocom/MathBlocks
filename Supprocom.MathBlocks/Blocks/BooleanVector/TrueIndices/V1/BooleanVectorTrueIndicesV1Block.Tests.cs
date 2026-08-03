namespace Supprocom.MathBlocks.Tests;

public sealed class BooleanVectorTrueIndicesV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("boolean-vector.true-indices@1");
}
