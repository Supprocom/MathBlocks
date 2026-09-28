namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>combinatorics.nonempty-subset-sums@1</c> operation contract.</summary>
public sealed class CombinatoricsNonemptySubsetSumsV1BlockTests
{
    /// <summary>Checks the <c>combinatorics.nonempty-subset-sums@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("combinatorics.nonempty-subset-sums@1");
}
