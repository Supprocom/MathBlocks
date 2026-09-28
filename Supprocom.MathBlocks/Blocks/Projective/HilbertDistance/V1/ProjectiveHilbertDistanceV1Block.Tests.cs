namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>projective.hilbert-distance@1</c> operation contract.</summary>
public sealed class ProjectiveHilbertDistanceV1BlockTests
{
    /// <summary>Checks the <c>projective.hilbert-distance@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("projective.hilbert-distance@1");
}
