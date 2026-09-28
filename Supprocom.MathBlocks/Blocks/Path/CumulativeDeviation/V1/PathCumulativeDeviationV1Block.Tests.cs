namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>path.cumulative-deviation@1</c> operation contract.</summary>
public sealed class PathCumulativeDeviationV1BlockTests
{
    /// <summary>Checks the <c>path.cumulative-deviation@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("path.cumulative-deviation@1");
}
