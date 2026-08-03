namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarArcTangent2V1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.arc-tangent-2@1");
}
