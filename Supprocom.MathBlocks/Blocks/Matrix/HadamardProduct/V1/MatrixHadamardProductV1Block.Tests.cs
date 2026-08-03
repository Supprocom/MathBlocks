namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixHadamardProductV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.hadamard-product@1");
}
