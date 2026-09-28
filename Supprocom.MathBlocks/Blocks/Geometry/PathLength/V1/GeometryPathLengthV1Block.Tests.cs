namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>geometry.path-length@1</c> operation contract.</summary>
public sealed class GeometryPathLengthV1BlockTests
{
    /// <summary>Checks the <c>geometry.path-length@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("geometry.path-length@1");
}
