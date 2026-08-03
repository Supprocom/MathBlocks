namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarReciprocalV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.reciprocal@1");
}
