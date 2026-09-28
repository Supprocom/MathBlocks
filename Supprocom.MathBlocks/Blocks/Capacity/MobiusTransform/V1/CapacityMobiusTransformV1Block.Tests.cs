namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>capacity.mobius-transform@1</c> operation contract.</summary>
public sealed class CapacityMobiusTransformV1BlockTests
{
    /// <summary>Checks the <c>capacity.mobius-transform@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("capacity.mobius-transform@1");
}
