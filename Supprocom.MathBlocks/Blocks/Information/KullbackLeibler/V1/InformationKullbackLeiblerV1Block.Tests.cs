namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>information.kullback-leibler@1</c> operation contract.</summary>
public sealed class InformationKullbackLeiblerV1BlockTests
{
    /// <summary>Checks the <c>information.kullback-leibler@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("information.kullback-leibler@1");
}
