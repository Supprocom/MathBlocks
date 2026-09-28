namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>geometry.signed-polygon-area@1</c> operation contract.</summary>
public sealed class GeometrySignedPolygonAreaV1BlockTests
{
    /// <summary>Checks the <c>geometry.signed-polygon-area@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("geometry.signed-polygon-area@1");
}
