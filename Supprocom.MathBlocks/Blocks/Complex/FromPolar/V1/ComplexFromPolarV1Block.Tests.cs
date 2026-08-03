namespace Supprocom.MathBlocks.Tests;

public sealed class ComplexFromPolarV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("complex.from-polar@1");
}
