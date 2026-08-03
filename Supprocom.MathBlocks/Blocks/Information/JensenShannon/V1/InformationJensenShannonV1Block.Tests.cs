namespace Supprocom.MathBlocks.Tests;

public sealed class InformationJensenShannonV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("information.jensen-shannon@1");
}
