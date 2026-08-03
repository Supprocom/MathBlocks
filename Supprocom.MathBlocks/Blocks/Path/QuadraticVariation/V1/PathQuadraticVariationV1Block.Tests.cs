namespace Supprocom.MathBlocks.Tests;

public sealed class PathQuadraticVariationV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("path.quadratic-variation@1");
}
