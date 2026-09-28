namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>information.cross-entropy@1</c> operation contract.</summary>
public sealed class InformationCrossEntropyV1BlockTests
{
    /// <summary>Checks the <c>information.cross-entropy@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("information.cross-entropy@1");
}
