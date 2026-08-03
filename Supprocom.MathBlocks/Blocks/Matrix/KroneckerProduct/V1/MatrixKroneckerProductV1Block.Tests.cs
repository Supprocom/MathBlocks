namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixKroneckerProductV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.kronecker-product@1");
}
