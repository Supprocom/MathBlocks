namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>geometry.halfspace-depth@1</c> operation contract.</summary>
public sealed class GeometryHalfspaceDepthV1BlockTests
{
    /// <summary>Checks the <c>geometry.halfspace-depth@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("geometry.halfspace-depth@1");
}
