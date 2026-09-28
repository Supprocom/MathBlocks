namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>order.isotonic-regression@1</c> operation contract.</summary>
public sealed class OrderIsotonicRegressionV1BlockTests
{
    /// <summary>Checks the <c>order.isotonic-regression@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("order.isotonic-regression@1");
}
