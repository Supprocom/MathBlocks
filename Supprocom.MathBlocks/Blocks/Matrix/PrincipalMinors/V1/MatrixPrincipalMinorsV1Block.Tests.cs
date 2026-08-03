namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixPrincipalMinorsV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.principal-minors@1");
}
