namespace Supprocom.MathBlocks.Tests;

public sealed class BooleanVectorAndV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("boolean-vector.and@1");
}
