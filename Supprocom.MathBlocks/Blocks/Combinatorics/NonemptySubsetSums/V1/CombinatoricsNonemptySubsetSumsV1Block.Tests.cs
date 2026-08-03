namespace Supprocom.MathBlocks.Tests;

public sealed class CombinatoricsNonemptySubsetSumsV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("combinatorics.nonempty-subset-sums@1");
}
