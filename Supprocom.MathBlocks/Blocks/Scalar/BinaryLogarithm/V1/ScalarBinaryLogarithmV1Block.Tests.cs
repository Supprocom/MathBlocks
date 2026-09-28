namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.binary-logarithm@1</c> operation contract.</summary>
public sealed class ScalarBinaryLogarithmV1BlockTests
{
    /// <summary>Checks the <c>scalar.binary-logarithm@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.binary-logarithm@1");
}
