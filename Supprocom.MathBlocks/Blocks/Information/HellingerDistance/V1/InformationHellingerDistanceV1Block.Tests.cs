namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>information.hellinger-distance@1</c> operation contract.</summary>
public sealed class InformationHellingerDistanceV1BlockTests
{
    /// <summary>Checks the <c>information.hellinger-distance@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("information.hellinger-distance@1");
}
