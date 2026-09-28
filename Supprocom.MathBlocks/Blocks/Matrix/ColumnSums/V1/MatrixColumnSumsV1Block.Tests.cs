namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.column-sums@1</c> operation contract.</summary>
public sealed class MatrixColumnSumsV1BlockTests
{
    /// <summary>Checks the <c>matrix.column-sums@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.column-sums@1");
}
