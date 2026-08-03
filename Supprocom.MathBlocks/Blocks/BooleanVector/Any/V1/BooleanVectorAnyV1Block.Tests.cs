namespace Supprocom.MathBlocks.Tests;

public sealed class BooleanVectorAnyV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("boolean-vector.any@1");
}
