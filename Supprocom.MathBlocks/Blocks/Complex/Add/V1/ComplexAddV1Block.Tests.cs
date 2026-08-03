namespace Supprocom.MathBlocks.Tests;

public sealed class ComplexAddV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("complex.add@1");
}
