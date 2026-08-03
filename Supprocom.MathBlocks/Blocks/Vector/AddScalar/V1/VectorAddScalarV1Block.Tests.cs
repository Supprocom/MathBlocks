namespace Supprocom.MathBlocks.Tests;

public sealed class VectorAddScalarV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.add-scalar@1");
}
