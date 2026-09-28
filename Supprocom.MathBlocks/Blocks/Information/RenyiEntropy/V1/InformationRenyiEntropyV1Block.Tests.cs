namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>information.renyi-entropy@1</c> operation contract.</summary>
public sealed class InformationRenyiEntropyV1BlockTests
{
    /// <summary>Checks the <c>information.renyi-entropy@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("information.renyi-entropy@1");
}
