namespace Supprocom.MathBlocks.Tests;

public sealed class VectorGeometricMeanV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.geometric-mean@1");
}
