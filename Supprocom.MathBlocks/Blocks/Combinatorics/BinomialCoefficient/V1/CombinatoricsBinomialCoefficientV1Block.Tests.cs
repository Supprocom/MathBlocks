namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>combinatorics.binomial-coefficient@1</c> operation contract.</summary>
public sealed class CombinatoricsBinomialCoefficientV1BlockTests
{
    /// <summary>Checks the <c>combinatorics.binomial-coefficient@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("combinatorics.binomial-coefficient@1");
}
