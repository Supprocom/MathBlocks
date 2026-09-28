namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>capacity.is-submodular@1</c> operation contract.</summary>
public sealed class CapacityIsSubmodularV1BlockTests
{
    /// <summary>Checks the <c>capacity.is-submodular@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("capacity.is-submodular@1");
}
