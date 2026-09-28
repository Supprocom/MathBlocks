namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>path.first-passage-index@1</c> operation contract.</summary>
public sealed class PathFirstPassageIndexV1BlockTests
{
    /// <summary>Checks the <c>path.first-passage-index@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("path.first-passage-index@1");
}
