namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>shape.is-completely-monotone@1</c> operation contract.</summary>
public sealed class ShapeIsCompletelyMonotoneV1BlockTests
{
    /// <summary>Checks the <c>shape.is-completely-monotone@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("shape.is-completely-monotone@1");
}
