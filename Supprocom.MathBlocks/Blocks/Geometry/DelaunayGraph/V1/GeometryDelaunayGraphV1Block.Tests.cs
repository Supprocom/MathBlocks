namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>geometry.delaunay-graph@1</c> operation contract.</summary>
public sealed class GeometryDelaunayGraphV1BlockTests
{
    /// <summary>Checks the <c>geometry.delaunay-graph@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("geometry.delaunay-graph@1");
}
