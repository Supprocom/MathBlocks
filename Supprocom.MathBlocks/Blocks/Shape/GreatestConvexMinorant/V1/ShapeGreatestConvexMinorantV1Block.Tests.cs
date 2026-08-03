namespace Supprocom.MathBlocks.Tests;

public sealed class ShapeGreatestConvexMinorantV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("shape.greatest-convex-minorant@1");
}
