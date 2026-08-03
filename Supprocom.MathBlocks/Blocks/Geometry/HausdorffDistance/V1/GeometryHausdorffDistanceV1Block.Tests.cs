namespace Supprocom.MathBlocks.Tests;

public sealed class GeometryHausdorffDistanceV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("geometry.hausdorff-distance@1");
}
