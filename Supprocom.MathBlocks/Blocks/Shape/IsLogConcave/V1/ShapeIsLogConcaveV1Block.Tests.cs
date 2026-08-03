namespace Supprocom.MathBlocks.Tests;

public sealed class ShapeIsLogConcaveV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("shape.is-log-concave@1");
}
