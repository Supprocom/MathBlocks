namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>shape.least-concave-majorant@1</c> operation contract.</summary>
public sealed class ShapeLeastConcaveMajorantV1BlockTests
{
    /// <summary>Checks the <c>shape.least-concave-majorant@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("shape.least-concave-majorant@1");
}
