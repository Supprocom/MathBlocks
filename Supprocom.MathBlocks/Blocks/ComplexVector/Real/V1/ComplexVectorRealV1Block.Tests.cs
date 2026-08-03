namespace Supprocom.MathBlocks.Tests;

public sealed class ComplexVectorRealV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("complex-vector.real@1");
}
