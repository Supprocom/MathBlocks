namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.maximum@1</c> operation contract.</summary>
public sealed class ScalarMaximumV1BlockTests
{
    /// <summary>Checks the <c>scalar.maximum@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.maximum@1");
}
