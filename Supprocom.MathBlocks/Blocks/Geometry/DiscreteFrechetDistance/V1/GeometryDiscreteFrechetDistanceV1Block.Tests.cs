namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>geometry.discrete-frechet-distance@1</c> operation contract.</summary>
public sealed class GeometryDiscreteFrechetDistanceV1BlockTests
{
    /// <summary>Checks the <c>geometry.discrete-frechet-distance@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("geometry.discrete-frechet-distance@1");
}
