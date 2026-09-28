namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.add@1</c> operation contract.</summary>
public sealed class VectorAddV1BlockTests
{
    /// <summary>Checks the <c>vector.add@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.add@1");
}
