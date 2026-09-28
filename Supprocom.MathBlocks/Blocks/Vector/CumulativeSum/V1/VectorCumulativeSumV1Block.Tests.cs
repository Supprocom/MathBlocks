namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.cumulative-sum@1</c> operation contract.</summary>
public sealed class VectorCumulativeSumV1BlockTests
{
    /// <summary>Checks the <c>vector.cumulative-sum@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.cumulative-sum@1");
}
