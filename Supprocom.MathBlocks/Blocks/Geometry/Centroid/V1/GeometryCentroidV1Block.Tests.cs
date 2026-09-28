namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>geometry.centroid@1</c> operation contract.</summary>
public sealed class GeometryCentroidV1BlockTests
{
    /// <summary>Checks the <c>geometry.centroid@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("geometry.centroid@1");
}
