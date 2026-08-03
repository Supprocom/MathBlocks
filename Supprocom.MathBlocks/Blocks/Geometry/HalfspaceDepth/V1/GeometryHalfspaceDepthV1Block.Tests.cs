namespace Supprocom.MathBlocks.Tests;

public sealed class GeometryHalfspaceDepthV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("geometry.halfspace-depth@1");
}
