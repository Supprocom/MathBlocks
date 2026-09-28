namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>extension.whitney@1</c> operation contract.</summary>
public sealed class ExtensionWhitneyV1BlockTests
{
    /// <summary>Checks the <c>extension.whitney@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("extension.whitney@1");
}
