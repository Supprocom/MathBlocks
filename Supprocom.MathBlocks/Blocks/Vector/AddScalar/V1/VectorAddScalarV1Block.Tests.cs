namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.add-scalar@1</c> operation contract.</summary>
public sealed class VectorAddScalarV1BlockTests
{
    /// <summary>Checks the <c>vector.add-scalar@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.add-scalar@1");
}
