namespace Supprocom.MathBlocks.Tests;

public sealed class ScalarCubeRootV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("scalar.cube-root@1");
}
