namespace Supprocom.MathBlocks.Tests;

public sealed class TransformWalshHadamardV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("transform.walsh-hadamard@1");
}
