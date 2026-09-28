namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>combinatorics.ballot-count@1</c> operation contract.</summary>
public sealed class CombinatoricsBallotCountV1BlockTests
{
    /// <summary>Checks the <c>combinatorics.ballot-count@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("combinatorics.ballot-count@1");
}
