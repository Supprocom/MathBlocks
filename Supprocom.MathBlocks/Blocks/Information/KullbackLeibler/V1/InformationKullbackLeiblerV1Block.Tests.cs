namespace Supprocom.MathBlocks.Tests;

public sealed class InformationKullbackLeiblerV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("information.kullback-leibler@1");
}
