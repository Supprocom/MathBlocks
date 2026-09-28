namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.hankel@1</c> operation contract.</summary>
public sealed class MatrixHankelV1BlockTests
{
    /// <summary>Checks the <c>matrix.hankel@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.hankel@1");
}
