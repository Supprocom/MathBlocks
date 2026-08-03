namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixDeterminantV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.determinant@1");
}
