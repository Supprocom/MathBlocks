namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.logit@1</c> operation contract.</summary>
public sealed class ScalarLogitV1BlockTests
{
    /// <summary>Checks the <c>scalar.logit@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.logit@1");
}
