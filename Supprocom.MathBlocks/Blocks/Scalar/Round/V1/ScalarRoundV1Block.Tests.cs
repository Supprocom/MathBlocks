namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarRoundV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.round@1");
}
