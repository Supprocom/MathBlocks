namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>path.hysteresis@1</c> operation contract.</summary>
public sealed class PathHysteresisV1BlockTests
{
    /// <summary>Checks the <c>path.hysteresis@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("path.hysteresis@1");
}
