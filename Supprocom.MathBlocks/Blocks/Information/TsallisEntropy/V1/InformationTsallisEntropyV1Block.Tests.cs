namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>information.tsallis-entropy@1</c> operation contract.</summary>
public sealed class InformationTsallisEntropyV1BlockTests
{
    /// <summary>Checks the <c>information.tsallis-entropy@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("information.tsallis-entropy@1");
}
