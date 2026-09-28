namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.slice@1</c> operation contract.</summary>
public sealed class VectorSliceV1BlockTests
{
    /// <summary>Checks the <c>vector.slice@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.slice@1");
}
