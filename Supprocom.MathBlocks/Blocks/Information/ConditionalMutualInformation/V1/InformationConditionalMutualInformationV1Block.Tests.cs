namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>information.conditional-mutual-information@1</c> operation contract.</summary>
public sealed class InformationConditionalMutualInformationV1BlockTests
{
    /// <summary>Checks the <c>information.conditional-mutual-information@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("information.conditional-mutual-information@1");
}
