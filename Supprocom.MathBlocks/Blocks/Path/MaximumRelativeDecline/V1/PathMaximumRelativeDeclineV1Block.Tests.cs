namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>path.maximum-relative-decline@1</c> operation contract.</summary>
public sealed class PathMaximumRelativeDeclineV1BlockTests
{
    /// <summary>Checks the <c>path.maximum-relative-decline@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("path.maximum-relative-decline@1");
}
