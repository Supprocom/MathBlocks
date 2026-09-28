namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.normalize-l2@1</c> operation contract.</summary>
public sealed class VectorNormalizeL2V1BlockTests
{
    /// <summary>Checks the <c>vector.normalize-l2@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.normalize-l2@1");
}
