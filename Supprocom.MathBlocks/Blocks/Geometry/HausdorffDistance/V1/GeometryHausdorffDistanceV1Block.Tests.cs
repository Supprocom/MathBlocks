namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>geometry.hausdorff-distance@1</c> operation contract.</summary>
public sealed class GeometryHausdorffDistanceV1BlockTests
{
    /// <summary>Checks the <c>geometry.hausdorff-distance@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("geometry.hausdorff-distance@1");
}
