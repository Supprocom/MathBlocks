namespace Supprocom.MathBlocks.Tests;

public sealed class ComplexMultiplyV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("complex.multiply@1");
}
