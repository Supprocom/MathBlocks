namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.unique@1</c> operation contract.</summary>
public sealed class VectorUniqueV1BlockTests
{
    /// <summary>Checks the <c>vector.unique@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.unique@1");
}
