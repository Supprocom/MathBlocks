namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>shape.greatest-convex-minorant@1</c> operation contract.</summary>
public sealed class ShapeGreatestConvexMinorantV1BlockTests
{
    /// <summary>Checks the <c>shape.greatest-convex-minorant@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("shape.greatest-convex-minorant@1");
}
