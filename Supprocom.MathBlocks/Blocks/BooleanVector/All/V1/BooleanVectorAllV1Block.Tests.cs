namespace Supprocom.MathBlocks.Tests;

public sealed class BooleanVectorAllV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("boolean-vector.all@1");
}
