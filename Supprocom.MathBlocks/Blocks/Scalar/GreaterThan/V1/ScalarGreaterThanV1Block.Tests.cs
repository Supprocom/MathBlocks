namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.greater-than@1</c> operation contract.</summary>
public sealed class ScalarGreaterThanV1BlockTests
{
    /// <summary>Checks the <c>scalar.greater-than@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.greater-than@1");
}
