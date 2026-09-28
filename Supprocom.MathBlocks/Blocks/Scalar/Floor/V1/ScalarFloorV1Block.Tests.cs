namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.floor@1</c> operation contract.</summary>
public sealed class ScalarFloorV1BlockTests
{
    /// <summary>Checks the <c>scalar.floor@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.floor@1");
}
