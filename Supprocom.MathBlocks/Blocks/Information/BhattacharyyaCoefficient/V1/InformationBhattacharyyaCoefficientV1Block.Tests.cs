namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>information.bhattacharyya-coefficient@1</c> operation contract.</summary>
public sealed class InformationBhattacharyyaCoefficientV1BlockTests
{
    /// <summary>Checks the <c>information.bhattacharyya-coefficient@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("information.bhattacharyya-coefficient@1");
}
