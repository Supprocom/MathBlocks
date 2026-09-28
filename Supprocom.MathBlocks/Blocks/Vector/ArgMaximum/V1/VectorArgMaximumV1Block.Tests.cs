namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.arg-maximum@1</c> operation contract.</summary>
public sealed class VectorArgMaximumV1BlockTests
{
    /// <summary>Checks the <c>vector.arg-maximum@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.arg-maximum@1");
}
