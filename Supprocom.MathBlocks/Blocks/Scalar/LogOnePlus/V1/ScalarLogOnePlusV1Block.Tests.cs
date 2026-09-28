namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.log-one-plus@1</c> operation contract.</summary>
public sealed class ScalarLogOnePlusV1BlockTests
{
    /// <summary>Checks the <c>scalar.log-one-plus@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.log-one-plus@1");
}
