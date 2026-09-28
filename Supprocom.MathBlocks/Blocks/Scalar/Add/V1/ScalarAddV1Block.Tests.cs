namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.add@1</c> operation contract.</summary>
public sealed class ScalarAddV1BlockTests
{
    /// <summary>Checks the <c>scalar.add@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.add@1");
}
