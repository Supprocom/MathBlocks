namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.square@1</c> operation contract.</summary>
public sealed class ScalarSquareV1BlockTests
{
    /// <summary>Checks the <c>scalar.square@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.square@1");
}
