namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>special.beta@1</c> operation contract.</summary>
public sealed class SpecialBetaV1BlockTests
{
    /// <summary>Checks the <c>special.beta@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("special.beta@1");
}
