namespace Supprocom.MathBlocks.Tests;

public sealed class TransformHaarV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("transform.haar@1");
}
