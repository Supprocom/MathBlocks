namespace Supprocom.MathBlocks.Tests;

public sealed class GeometryDistanceV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("geometry.distance@1");
}
