namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>path.lead-lag-transform@1</c> operation contract.</summary>
public sealed class PathLeadLagTransformV1BlockTests
{
    /// <summary>Checks the <c>path.lead-lag-transform@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("path.lead-lag-transform@1");
}
