namespace Supprocom.MathBlocks.Tests;

public sealed class GeometryDelaunayGraphV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("geometry.delaunay-graph@1");
}
