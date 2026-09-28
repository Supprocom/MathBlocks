namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.ceiling@1</c> operation contract.</summary>
public sealed class ScalarCeilingV1BlockTests
{
    /// <summary>Checks the <c>scalar.ceiling@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.ceiling@1");
}
