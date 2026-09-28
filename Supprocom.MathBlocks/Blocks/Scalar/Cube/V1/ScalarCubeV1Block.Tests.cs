namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.cube@1</c> operation contract.</summary>
public sealed class ScalarCubeV1BlockTests
{
    /// <summary>Checks the <c>scalar.cube@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.cube@1");
}
