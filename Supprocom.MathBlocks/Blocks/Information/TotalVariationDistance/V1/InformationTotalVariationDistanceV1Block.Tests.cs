namespace Supprocom.MathBlocks.Tests;

public sealed class InformationTotalVariationDistanceV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("information.total-variation-distance@1");
}
