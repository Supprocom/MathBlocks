namespace Supprocom.MathBlocks.Tests;

public sealed class GeometryContainsPointV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("geometry.contains-point@1");
}
