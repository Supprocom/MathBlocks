namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixToeplitzV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.toeplitz@1");
}
