namespace Supprocom.MathBlocks.Tests;

public sealed class SpecialBetaV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("special.beta@1");
}
