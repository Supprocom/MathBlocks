namespace Supprocom.MathBlocks.Tests;

public sealed class ComplexCreateV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("complex.create@1");
}
