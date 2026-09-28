namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>information.jensen-shannon@1</c> operation contract.</summary>
public sealed class InformationJensenShannonV1BlockTests
{
    /// <summary>Checks the <c>information.jensen-shannon@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("information.jensen-shannon@1");
}
