namespace Supprocom.MathBlocks.Tests;

public sealed class GeometryFisherRaoDistanceV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("geometry.fisher-rao-distance@1");
}
