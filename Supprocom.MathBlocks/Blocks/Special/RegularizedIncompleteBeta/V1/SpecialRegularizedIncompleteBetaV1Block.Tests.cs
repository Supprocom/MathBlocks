namespace Supprocom.MathBlocks.Tests;

public sealed class SpecialRegularizedIncompleteBetaV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("special.regularized-incomplete-beta@1");
}
