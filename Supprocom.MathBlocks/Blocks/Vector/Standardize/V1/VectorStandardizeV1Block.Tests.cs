namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.standardize@1</c> operation contract.</summary>
public sealed class VectorStandardizeV1BlockTests
{
    /// <summary>Checks the <c>vector.standardize@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.standardize@1");
}
