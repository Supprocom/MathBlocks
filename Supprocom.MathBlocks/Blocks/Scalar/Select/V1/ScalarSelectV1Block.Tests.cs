namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.select@1</c> operation contract.</summary>
public sealed class ScalarSelectV1BlockTests
{
    /// <summary>Checks the <c>scalar.select@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.select@1");
}
