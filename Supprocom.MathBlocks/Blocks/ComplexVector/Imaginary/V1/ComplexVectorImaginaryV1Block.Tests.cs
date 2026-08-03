namespace Supprocom.MathBlocks.Tests;

public sealed class ComplexVectorImaginaryV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("complex-vector.imaginary@1");
}
