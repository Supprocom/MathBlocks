namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.logistic@1</c> operation contract.</summary>
public sealed class ScalarLogisticV1BlockTests
{
    /// <summary>Checks the <c>scalar.logistic@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.logistic@1");
}
