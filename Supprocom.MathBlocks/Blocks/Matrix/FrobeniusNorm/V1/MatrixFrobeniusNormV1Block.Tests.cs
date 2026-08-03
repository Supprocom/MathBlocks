namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixFrobeniusNormV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.frobenius-norm@1");
}
