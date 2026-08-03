namespace Supprocom.MathBlocks.Tests;

public sealed class PathRunLengthEncodeV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("path.run-length-encode@1");
}
