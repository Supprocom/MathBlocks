namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixHankelV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.hankel@1");
}
