namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.greater-than@1</c> operation contract.</summary>
public sealed class VectorGreaterThanV1BlockTests
{
    /// <summary>Checks the <c>vector.greater-than@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.greater-than@1");
}
