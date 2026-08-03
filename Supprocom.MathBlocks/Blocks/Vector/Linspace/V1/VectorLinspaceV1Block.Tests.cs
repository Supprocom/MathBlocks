namespace Supprocom.MathBlocks.Tests;

public sealed class VectorLinspaceV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.linspace@1");
}
