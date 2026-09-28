namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.integer-power@1</c> operation contract.</summary>
public sealed class MatrixIntegerPowerV1BlockTests
{
    /// <summary>Checks the <c>matrix.integer-power@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.integer-power@1");
}
