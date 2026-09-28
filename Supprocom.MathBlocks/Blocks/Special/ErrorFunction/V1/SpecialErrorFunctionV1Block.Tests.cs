namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>special.error-function@1</c> operation contract.</summary>
public sealed class SpecialErrorFunctionV1BlockTests
{
    /// <summary>Checks the <c>special.error-function@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("special.error-function@1");
}
