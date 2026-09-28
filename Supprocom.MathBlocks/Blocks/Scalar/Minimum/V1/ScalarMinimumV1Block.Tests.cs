namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.minimum@1</c> operation contract.</summary>
public sealed class ScalarMinimumV1BlockTests
{
    /// <summary>Checks the <c>scalar.minimum@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.minimum@1");
}
