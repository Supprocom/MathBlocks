namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>information.binary-shannon-entropy@1</c> operation contract.</summary>
public sealed class InformationBinaryShannonEntropyV1BlockTests
{
    /// <summary>Checks the <c>information.binary-shannon-entropy@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("information.binary-shannon-entropy@1");
}
