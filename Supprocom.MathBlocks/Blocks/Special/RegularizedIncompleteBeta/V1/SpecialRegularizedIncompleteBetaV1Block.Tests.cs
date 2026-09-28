namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>special.regularized-incomplete-beta@1</c> operation contract.</summary>
public sealed class SpecialRegularizedIncompleteBetaV1BlockTests
{
    /// <summary>Checks the <c>special.regularized-incomplete-beta@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("special.regularized-incomplete-beta@1");
}
