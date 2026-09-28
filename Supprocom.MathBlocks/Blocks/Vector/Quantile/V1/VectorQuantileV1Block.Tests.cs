namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.quantile@1</c> operation contract.</summary>
public sealed class VectorQuantileV1BlockTests
{
    /// <summary>Checks the <c>vector.quantile@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.quantile@1");
}
