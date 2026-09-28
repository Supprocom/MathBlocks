namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.maximum@1</c> operation contract.</summary>
public sealed class VectorMaximumV1BlockTests
{
    /// <summary>Checks the <c>vector.maximum@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.maximum@1");
}
