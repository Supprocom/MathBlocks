namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.normalize-l1@1</c> operation contract.</summary>
public sealed class VectorNormalizeL1V1BlockTests
{
    /// <summary>Checks the <c>vector.normalize-l1@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.normalize-l1@1");
}
