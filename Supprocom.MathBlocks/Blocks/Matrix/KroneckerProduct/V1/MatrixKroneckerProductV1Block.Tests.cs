namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.kronecker-product@1</c> operation contract.</summary>
public sealed class MatrixKroneckerProductV1BlockTests
{
    /// <summary>Checks the <c>matrix.kronecker-product@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.kronecker-product@1");
}
