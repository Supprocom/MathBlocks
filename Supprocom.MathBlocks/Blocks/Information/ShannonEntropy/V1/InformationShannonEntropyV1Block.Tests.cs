namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>information.shannon-entropy@1</c> operation contract.</summary>
public sealed class InformationShannonEntropyV1BlockTests
{
    /// <summary>Checks the <c>information.shannon-entropy@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("information.shannon-entropy@1");
}
