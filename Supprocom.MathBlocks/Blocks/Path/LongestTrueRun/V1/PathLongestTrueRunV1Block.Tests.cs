namespace Supprocom.MathBlocks.Tests;

public sealed class PathLongestTrueRunV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("path.longest-true-run@1");
}
