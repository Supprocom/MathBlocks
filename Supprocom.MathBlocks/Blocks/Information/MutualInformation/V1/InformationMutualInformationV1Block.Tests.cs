namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>information.mutual-information@1</c> operation contract.</summary>
public sealed class InformationMutualInformationV1BlockTests
{
    /// <summary>Checks the <c>information.mutual-information@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("information.mutual-information@1");
}
