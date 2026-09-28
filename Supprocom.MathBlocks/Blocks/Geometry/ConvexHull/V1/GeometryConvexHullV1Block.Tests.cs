namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>geometry.convex-hull@1</c> operation contract.</summary>
public sealed class GeometryConvexHullV1BlockTests
{
    /// <summary>Checks the <c>geometry.convex-hull@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("geometry.convex-hull@1");
}
