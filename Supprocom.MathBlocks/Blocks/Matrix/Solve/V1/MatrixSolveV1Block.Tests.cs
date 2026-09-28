namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.solve@1</c> operation contract.</summary>
public sealed class MatrixSolveV1BlockTests
{
    /// <summary>Checks the <c>matrix.solve@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.solve@1");
}
