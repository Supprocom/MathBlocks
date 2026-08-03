namespace Supprocom.MathBlocks.Tests;

public sealed class ComplexConjugateV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("complex.conjugate@1");
}
