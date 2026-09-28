namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.sign@1</c> operation contract.</summary>
public sealed class VectorSignV1BlockTests
{
    /// <summary>Checks the <c>vector.sign@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.sign@1");
}
