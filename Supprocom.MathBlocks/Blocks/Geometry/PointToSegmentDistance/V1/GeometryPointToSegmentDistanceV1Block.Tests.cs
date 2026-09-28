namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>geometry.point-to-segment-distance@1</c> operation contract.</summary>
public sealed class GeometryPointToSegmentDistanceV1BlockTests
{
    /// <summary>Checks the <c>geometry.point-to-segment-distance@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("geometry.point-to-segment-distance@1");
}
