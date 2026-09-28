namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.prepend@1</c> operation contract.</summary>
public sealed class VectorPrependV1BlockTests
{
    /// <summary>Checks the <c>vector.prepend@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.prepend@1");
}
