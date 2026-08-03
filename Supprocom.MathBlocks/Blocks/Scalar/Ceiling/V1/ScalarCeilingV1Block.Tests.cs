namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarCeilingV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.ceiling@1");
}
