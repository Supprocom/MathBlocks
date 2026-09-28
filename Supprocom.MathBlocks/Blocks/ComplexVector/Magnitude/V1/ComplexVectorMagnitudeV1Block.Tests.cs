namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>complex-vector.magnitude@1</c> operation contract.</summary>
public sealed class ComplexVectorMagnitudeV1BlockTests
{
    /// <summary>Checks the <c>complex-vector.magnitude@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("complex-vector.magnitude@1");
}
