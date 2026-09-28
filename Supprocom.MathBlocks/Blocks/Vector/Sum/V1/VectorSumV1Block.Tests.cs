namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.sum@1</c> operation contract.</summary>
public sealed class VectorSumV1BlockTests
{
    /// <summary>Checks the <c>vector.sum@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.sum@1");
}
