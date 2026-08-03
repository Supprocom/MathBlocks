namespace Supprocom.MathBlocks.Tests;

public sealed class GeometryPathLengthV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("geometry.path-length@1");
}
