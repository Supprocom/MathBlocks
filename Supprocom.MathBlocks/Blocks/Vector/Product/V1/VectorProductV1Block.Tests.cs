namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.product@1</c> operation contract.</summary>
public sealed class VectorProductV1BlockTests
{
    /// <summary>Checks the <c>vector.product@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.product@1");
}
