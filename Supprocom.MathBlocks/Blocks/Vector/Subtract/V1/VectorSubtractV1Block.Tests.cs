namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.subtract@1</c> operation contract.</summary>
public sealed class VectorSubtractV1BlockTests
{
    /// <summary>Checks the <c>vector.subtract@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.subtract@1");
}
