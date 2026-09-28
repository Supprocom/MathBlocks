namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>geometry.perimeter@1</c> operation contract.</summary>
public sealed class GeometryPerimeterV1BlockTests
{
    /// <summary>Checks the <c>geometry.perimeter@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("geometry.perimeter@1");
}
