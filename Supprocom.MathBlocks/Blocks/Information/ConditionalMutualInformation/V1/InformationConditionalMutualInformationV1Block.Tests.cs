namespace Supprocom.MathBlocks.Tests;

public sealed class InformationConditionalMutualInformationV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("information.conditional-mutual-information@1");
}
