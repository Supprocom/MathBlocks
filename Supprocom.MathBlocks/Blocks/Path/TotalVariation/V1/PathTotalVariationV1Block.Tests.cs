namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>path.total-variation@1</c> operation contract.</summary>
public sealed class PathTotalVariationV1BlockTests
{
    /// <summary>Checks the <c>path.total-variation@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("path.total-variation@1");
}
