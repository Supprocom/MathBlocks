namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>geometry.distance@1</c> operation contract.</summary>
public sealed class GeometryDistanceV1BlockTests
{
    /// <summary>Checks the <c>geometry.distance@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("geometry.distance@1");
}
