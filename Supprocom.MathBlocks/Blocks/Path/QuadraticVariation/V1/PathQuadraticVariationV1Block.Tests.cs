namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>path.quadratic-variation@1</c> operation contract.</summary>
public sealed class PathQuadraticVariationV1BlockTests
{
    /// <summary>Checks the <c>path.quadratic-variation@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("path.quadratic-variation@1");
}
