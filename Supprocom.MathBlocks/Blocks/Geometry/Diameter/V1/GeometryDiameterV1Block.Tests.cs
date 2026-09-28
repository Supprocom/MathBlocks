namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>geometry.diameter@1</c> operation contract.</summary>
public sealed class GeometryDiameterV1BlockTests
{
    /// <summary>Checks the <c>geometry.diameter@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("geometry.diameter@1");
}
