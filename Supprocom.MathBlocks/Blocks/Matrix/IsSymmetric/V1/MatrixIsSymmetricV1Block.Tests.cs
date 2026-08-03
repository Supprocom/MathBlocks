namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixIsSymmetricV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.is-symmetric@1");
}
