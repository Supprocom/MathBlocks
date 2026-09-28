namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.absolute@1</c> operation contract.</summary>
public sealed class VectorAbsoluteV1BlockTests
{
    /// <summary>Checks the <c>vector.absolute@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.absolute@1");
}
