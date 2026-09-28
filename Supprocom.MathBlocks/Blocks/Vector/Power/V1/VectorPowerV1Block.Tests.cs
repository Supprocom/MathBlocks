namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.power@1</c> operation contract.</summary>
public sealed class VectorPowerV1BlockTests
{
    /// <summary>Checks the <c>vector.power@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.power@1");
}
