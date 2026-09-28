namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.softplus@1</c> operation contract.</summary>
public sealed class ScalarSoftplusV1BlockTests
{
    /// <summary>Checks the <c>scalar.softplus@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.softplus@1");
}
