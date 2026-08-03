namespace Supprocom.MathBlocks.Tests;

public sealed class GeometryConvexHullV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("geometry.convex-hull@1");
}
