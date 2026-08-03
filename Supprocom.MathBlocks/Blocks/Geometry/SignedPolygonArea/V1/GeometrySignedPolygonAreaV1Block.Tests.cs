namespace Supprocom.MathBlocks.Tests;

public sealed class GeometrySignedPolygonAreaV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("geometry.signed-polygon-area@1");
}
