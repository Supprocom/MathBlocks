namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>boolean-vector.true-count@1</c> operation contract.</summary>
public sealed class BooleanVectorTrueCountV1BlockTests
{
    /// <summary>Checks the <c>boolean-vector.true-count@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("boolean-vector.true-count@1");
}
