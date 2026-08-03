namespace Supprocom.MathBlocks.Tests;

public sealed class GeometryGabrielGraphV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("geometry.gabriel-graph@1");
}
