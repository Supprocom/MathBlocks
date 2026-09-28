namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>path.reflected-cumulative-sum@1</c> operation contract.</summary>
public sealed class PathReflectedCumulativeSumV1BlockTests
{
    /// <summary>Checks the <c>path.reflected-cumulative-sum@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("path.reflected-cumulative-sum@1");
}
