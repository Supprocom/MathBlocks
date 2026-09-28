namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.median@1</c> operation contract.</summary>
public sealed class VectorMedianV1BlockTests
{
    /// <summary>Checks the <c>vector.median@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.median@1");
}
