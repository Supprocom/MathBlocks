namespace Supprocom.MathBlocks.Tests;

public sealed class ComplexNaturalLogarithmV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("complex.natural-logarithm@1");
}
