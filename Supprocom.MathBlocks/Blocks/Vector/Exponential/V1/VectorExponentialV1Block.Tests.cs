namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.exponential@1</c> operation contract.</summary>
public sealed class VectorExponentialV1BlockTests
{
    /// <summary>Checks the <c>vector.exponential@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.exponential@1");
}
