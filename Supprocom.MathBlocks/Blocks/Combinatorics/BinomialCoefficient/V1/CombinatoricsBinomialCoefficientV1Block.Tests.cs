namespace Supprocom.MathBlocks.Tests;

public sealed class CombinatoricsBinomialCoefficientV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("combinatorics.binomial-coefficient@1");
}
