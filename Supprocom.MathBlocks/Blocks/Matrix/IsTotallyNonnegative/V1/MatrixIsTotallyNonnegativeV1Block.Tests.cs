namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixIsTotallyNonnegativeV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.is-totally-nonnegative@1");
}
