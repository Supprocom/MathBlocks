namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>capacity.choquet-integral@1</c> operation contract.</summary>
public sealed class CapacityChoquetIntegralV1BlockTests
{
    /// <summary>Checks the <c>capacity.choquet-integral@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("capacity.choquet-integral@1");
}
