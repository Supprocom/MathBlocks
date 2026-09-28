namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.column@1</c> operation contract.</summary>
public sealed class MatrixColumnV1BlockTests
{
    /// <summary>Checks the <c>matrix.column@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.column@1");
}
