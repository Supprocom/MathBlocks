namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixIdentityV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.identity@1");
}
