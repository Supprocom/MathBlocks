namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.scale@1</c> operation contract.</summary>
public sealed class VectorScaleV1BlockTests
{
    /// <summary>Checks the <c>vector.scale@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.scale@1");
}
