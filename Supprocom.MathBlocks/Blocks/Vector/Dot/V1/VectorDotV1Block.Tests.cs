namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.dot@1</c> operation contract.</summary>
public sealed class VectorDotV1BlockTests
{
    /// <summary>Checks the <c>vector.dot@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.dot@1");
}
