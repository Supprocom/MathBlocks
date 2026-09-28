namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.absolute@1</c> operation contract.</summary>
public sealed class ScalarAbsoluteV1BlockTests
{
    /// <summary>Checks the <c>scalar.absolute@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.absolute@1");
}
