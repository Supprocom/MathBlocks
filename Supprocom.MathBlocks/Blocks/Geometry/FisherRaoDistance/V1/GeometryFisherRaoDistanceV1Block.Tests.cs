namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>geometry.fisher-rao-distance@1</c> operation contract.</summary>
public sealed class GeometryFisherRaoDistanceV1BlockTests
{
    /// <summary>Checks the <c>geometry.fisher-rao-distance@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("geometry.fisher-rao-distance@1");
}
