namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.sign@1</c> operation contract.</summary>
public sealed class ScalarSignV1BlockTests
{
    /// <summary>Checks the <c>scalar.sign@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.sign@1");
}
