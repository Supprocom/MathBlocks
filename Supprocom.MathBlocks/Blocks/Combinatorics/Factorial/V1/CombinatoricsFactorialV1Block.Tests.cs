namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>combinatorics.factorial@1</c> operation contract.</summary>
public sealed class CombinatoricsFactorialV1BlockTests
{
    /// <summary>Checks the <c>combinatorics.factorial@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("combinatorics.factorial@1");
}
