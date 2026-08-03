namespace Supprocom.MathBlocks.Tests;

public sealed class CombinatoricsFactorialV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("combinatorics.factorial@1");
}
