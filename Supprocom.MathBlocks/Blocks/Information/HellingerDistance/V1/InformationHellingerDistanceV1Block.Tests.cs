namespace Supprocom.MathBlocks.Tests;

public sealed class InformationHellingerDistanceV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("information.hellinger-distance@1");
}
