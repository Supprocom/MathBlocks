namespace Supprocom.MathBlocks.Tests;

public sealed class GeometryPolygonAreaV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("geometry.polygon-area@1");
}
