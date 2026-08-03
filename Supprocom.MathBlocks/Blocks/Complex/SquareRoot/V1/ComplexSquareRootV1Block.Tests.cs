namespace Supprocom.MathBlocks.Tests;

public sealed class ComplexSquareRootV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("complex.square-root@1");
}
