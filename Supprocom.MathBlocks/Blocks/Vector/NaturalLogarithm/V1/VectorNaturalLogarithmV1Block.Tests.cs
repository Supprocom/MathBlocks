namespace Supprocom.MathBlocks.Tests;

public sealed class VectorNaturalLogarithmV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.natural-logarithm@1");
}
