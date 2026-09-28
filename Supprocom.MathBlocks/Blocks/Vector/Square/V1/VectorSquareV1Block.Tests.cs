namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.square@1</c> operation contract.</summary>
public sealed class VectorSquareV1BlockTests
{
    /// <summary>Checks the <c>vector.square@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.square@1");
}
