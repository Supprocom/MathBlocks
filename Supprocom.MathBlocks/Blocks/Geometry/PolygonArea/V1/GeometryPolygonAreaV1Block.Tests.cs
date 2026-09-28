namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>geometry.polygon-area@1</c> operation contract.</summary>
public sealed class GeometryPolygonAreaV1BlockTests
{
    /// <summary>Checks the <c>geometry.polygon-area@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("geometry.polygon-area@1");
}
