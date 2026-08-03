namespace Supprocom.MathBlocks.Tests;

public sealed class CombinatoricsBallotCountV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("combinatorics.ballot-count@1");
}
