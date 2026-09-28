namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>path.maximum-decline@1</c> operation contract.</summary>
public sealed class PathMaximumDeclineV1BlockTests
{
    /// <summary>Checks the <c>path.maximum-decline@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("path.maximum-decline@1");
}
