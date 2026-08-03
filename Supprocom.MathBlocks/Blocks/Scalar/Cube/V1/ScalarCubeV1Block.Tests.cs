namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarCubeV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.cube@1");
}
