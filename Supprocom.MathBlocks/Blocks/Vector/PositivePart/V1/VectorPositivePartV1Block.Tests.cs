namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.positive-part@1</c> operation contract.</summary>
public sealed class VectorPositivePartV1BlockTests
{
    /// <summary>Checks the <c>vector.positive-part@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.positive-part@1");
}
