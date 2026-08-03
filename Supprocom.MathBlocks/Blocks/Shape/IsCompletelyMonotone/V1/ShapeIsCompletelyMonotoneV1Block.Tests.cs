namespace Supprocom.MathBlocks.Tests;

public sealed class ShapeIsCompletelyMonotoneV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("shape.is-completely-monotone@1");
}
