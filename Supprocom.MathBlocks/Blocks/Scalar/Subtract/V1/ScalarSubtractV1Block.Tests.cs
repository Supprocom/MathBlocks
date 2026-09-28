namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.subtract@1</c> operation contract.</summary>
public sealed class ScalarSubtractV1BlockTests
{
    /// <summary>Checks the <c>scalar.subtract@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.subtract@1");
}
