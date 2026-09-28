namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.positive-part@1</c> operation contract.</summary>
public sealed class ScalarPositivePartV1BlockTests
{
    /// <summary>Checks the <c>scalar.positive-part@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.positive-part@1");
}
