namespace Supprocom.MathBlocks.Tests;

public sealed class ComplexDivideV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("complex.divide@1");
}
