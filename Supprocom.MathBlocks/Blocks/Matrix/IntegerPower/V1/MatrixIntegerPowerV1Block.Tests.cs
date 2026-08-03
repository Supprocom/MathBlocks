namespace Supprocom.MathBlocks.Tests;

public sealed class MatrixIntegerPowerV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("matrix.integer-power@1");
}
