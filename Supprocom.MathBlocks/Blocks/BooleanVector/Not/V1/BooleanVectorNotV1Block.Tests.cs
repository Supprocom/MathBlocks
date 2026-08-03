namespace Supprocom.MathBlocks.Tests;

public sealed class BooleanVectorNotV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("boolean-vector.not@1");
}
