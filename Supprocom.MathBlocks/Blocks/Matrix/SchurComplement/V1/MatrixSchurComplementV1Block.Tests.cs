namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.schur-complement@1</c> operation contract.</summary>
public sealed class MatrixSchurComplementV1BlockTests
{
    /// <summary>Checks the <c>matrix.schur-complement@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.schur-complement@1");
}
