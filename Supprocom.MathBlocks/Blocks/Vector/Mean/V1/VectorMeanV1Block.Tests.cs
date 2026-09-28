namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.mean@1</c> operation contract.</summary>
public sealed class VectorMeanV1BlockTests
{
    /// <summary>Checks the <c>vector.mean@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.mean@1");
}
