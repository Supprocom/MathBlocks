namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>information.total-variation-distance@1</c> operation contract.</summary>
public sealed class InformationTotalVariationDistanceV1BlockTests
{
    /// <summary>Checks the <c>information.total-variation-distance@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("information.total-variation-distance@1");
}
