namespace Supprocom.MathBlocks.Tests;

public sealed class ComplexNegateV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("complex.negate@1");
}
