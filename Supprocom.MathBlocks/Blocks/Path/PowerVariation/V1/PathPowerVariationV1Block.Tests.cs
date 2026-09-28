namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>path.power-variation@1</c> operation contract.</summary>
public sealed class PathPowerVariationV1BlockTests
{
    /// <summary>Checks the <c>path.power-variation@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("path.power-variation@1");
}
