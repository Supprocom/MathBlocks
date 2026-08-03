namespace Supprocom.MathBlocks.Tests;

public sealed class InformationMutualInformationV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("information.mutual-information@1");
}
