namespace Supprocom.MathBlocks.Tests;

public sealed class GeometryPointToSegmentDistanceV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("geometry.point-to-segment-distance@1");
}
