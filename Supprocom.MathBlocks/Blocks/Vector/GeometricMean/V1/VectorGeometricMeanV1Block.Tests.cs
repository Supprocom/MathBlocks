namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.geometric-mean@1</c> operation contract.</summary>
public sealed class VectorGeometricMeanV1BlockTests
{
    /// <summary>Checks the <c>vector.geometric-mean@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.geometric-mean@1");
}
