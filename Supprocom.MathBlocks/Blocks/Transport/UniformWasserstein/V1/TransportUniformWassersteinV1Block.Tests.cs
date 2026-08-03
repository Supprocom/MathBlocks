namespace Supprocom.MathBlocks.Tests;

public sealed class TransportUniformWassersteinV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("transport.uniform-wasserstein@1");
}
