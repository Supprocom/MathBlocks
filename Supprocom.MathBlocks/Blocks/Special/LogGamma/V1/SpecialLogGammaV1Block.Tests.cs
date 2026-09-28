namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>special.log-gamma@1</c> operation contract.</summary>
public sealed class SpecialLogGammaV1BlockTests
{
    /// <summary>Checks the <c>special.log-gamma@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("special.log-gamma@1");
}
