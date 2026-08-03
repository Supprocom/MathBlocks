namespace Supprocom.MathBlocks.Tests;

public sealed class GeometryCircumradiusV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("geometry.circumradius@1");
}
