namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>geometry.simplicial-depth@1</c> operation contract.</summary>
public sealed class GeometrySimplicialDepthV1BlockTests
{
    /// <summary>Checks the <c>geometry.simplicial-depth@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("geometry.simplicial-depth@1");
}
