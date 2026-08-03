namespace Supprocom.MathBlocks.Tests;

public sealed class InformationBhattacharyyaCoefficientV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("information.bhattacharyya-coefficient@1");
}
