namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>complex.magnitude@1</c> operation contract.</summary>
public sealed class ComplexMagnitudeV1BlockTests
{
    /// <summary>Checks the <c>complex.magnitude@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("complex.magnitude@1");
}
