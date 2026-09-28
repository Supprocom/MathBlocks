namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>path.dynamic-time-warping@1</c> operation contract.</summary>
public sealed class PathDynamicTimeWarpingV1BlockTests
{
    /// <summary>Checks the <c>path.dynamic-time-warping@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("path.dynamic-time-warping@1");
}
