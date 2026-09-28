namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>complex.power@1</c> operation contract.</summary>
public sealed class ComplexPowerV1BlockTests
{
    /// <summary>Checks the <c>complex.power@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("complex.power@1");
}
