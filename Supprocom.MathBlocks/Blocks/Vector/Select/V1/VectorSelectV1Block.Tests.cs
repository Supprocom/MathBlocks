namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.select@1</c> operation contract.</summary>
public sealed class VectorSelectV1BlockTests
{
    /// <summary>Checks the <c>vector.select@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.select@1");
}
