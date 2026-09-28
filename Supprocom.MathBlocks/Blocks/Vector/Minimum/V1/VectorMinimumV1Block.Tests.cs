namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.minimum@1</c> operation contract.</summary>
public sealed class VectorMinimumV1BlockTests
{
    /// <summary>Checks the <c>vector.minimum@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.minimum@1");
}
