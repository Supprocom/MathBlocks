namespace Supprocom.MathBlocks.Tests;

public sealed class GeometryDiameterV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("geometry.diameter@1");
}
