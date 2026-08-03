namespace Supprocom.MathBlocks.Tests;

public sealed class ComplexVectorCreateV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("complex-vector.create@1");
}
