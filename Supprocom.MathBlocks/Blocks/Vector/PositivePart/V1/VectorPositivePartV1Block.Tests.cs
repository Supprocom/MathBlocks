namespace Supprocom.MathBlocks.Tests;

public sealed class VectorPositivePartV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.positive-part@1");
}
