namespace Supprocom.MathBlocks.Tests;

public sealed class PolynomialCubicRootsV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("polynomial.cubic-roots@1");
}
