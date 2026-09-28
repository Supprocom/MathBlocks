namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.divide@1</c> operation contract.</summary>
public sealed class ScalarDivideV1BlockTests
{
    /// <summary>Checks the <c>scalar.divide@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.divide@1");
}
