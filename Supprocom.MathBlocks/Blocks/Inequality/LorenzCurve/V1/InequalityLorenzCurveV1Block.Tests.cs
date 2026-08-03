namespace Supprocom.MathBlocks.Tests;

public sealed class InequalityLorenzCurveV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("inequality.lorenz-curve@1");
}
