namespace Supprocom.MathBlocks.Tests;

public sealed class GeometrySimplicialDepthV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("geometry.simplicial-depth@1");
}
