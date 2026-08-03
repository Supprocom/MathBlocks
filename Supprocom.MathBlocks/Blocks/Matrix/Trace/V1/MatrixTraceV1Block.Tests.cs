namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixTraceV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.trace@1");
}
