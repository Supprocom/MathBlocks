namespace Supprocom.MathBlocks.Tests;

public sealed class ShapeLeastConcaveMajorantV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("shape.least-concave-majorant@1");
}
