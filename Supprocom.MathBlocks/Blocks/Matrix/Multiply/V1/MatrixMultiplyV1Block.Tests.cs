namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.multiply@1</c> operation contract.</summary>
public sealed class MatrixMultiplyV1BlockTests
{
    /// <summary>Checks the <c>matrix.multiply@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.multiply@1");
}
