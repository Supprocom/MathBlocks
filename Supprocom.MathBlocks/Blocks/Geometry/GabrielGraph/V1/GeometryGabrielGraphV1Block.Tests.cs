namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>geometry.gabriel-graph@1</c> operation contract.</summary>
public sealed class GeometryGabrielGraphV1BlockTests
{
    /// <summary>Checks the <c>geometry.gabriel-graph@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("geometry.gabriel-graph@1");
}
