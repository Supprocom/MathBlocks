namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>survival.product-limit@1</c> operation contract.</summary>
public sealed class SurvivalProductLimitV1BlockTests
{
    /// <summary>Checks the <c>survival.product-limit@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("survival.product-limit@1");
}
