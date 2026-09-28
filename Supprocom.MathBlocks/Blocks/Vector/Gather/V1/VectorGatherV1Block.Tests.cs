namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.gather@1</c> operation contract.</summary>
public sealed class VectorGatherV1BlockTests
{
    /// <summary>Checks the <c>vector.gather@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.gather@1");
}
