namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.cumulative-product@1</c> operation contract.</summary>
public sealed class VectorCumulativeProductV1BlockTests
{
    /// <summary>Checks the <c>vector.cumulative-product@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.cumulative-product@1");
}
