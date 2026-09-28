namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.arg-minimum@1</c> operation contract.</summary>
public sealed class VectorArgMinimumV1BlockTests
{
    /// <summary>Checks the <c>vector.arg-minimum@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.arg-minimum@1");
}
