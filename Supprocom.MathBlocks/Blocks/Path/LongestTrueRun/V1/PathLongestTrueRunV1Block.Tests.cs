namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>path.longest-true-run@1</c> operation contract.</summary>
public sealed class PathLongestTrueRunV1BlockTests
{
    /// <summary>Checks the <c>path.longest-true-run@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("path.longest-true-run@1");
}
