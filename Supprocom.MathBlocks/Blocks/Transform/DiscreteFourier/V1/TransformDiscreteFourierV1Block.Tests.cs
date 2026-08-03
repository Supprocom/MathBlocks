namespace Supprocom.MathBlocks.Tests;

public sealed class TransformDiscreteFourierV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("transform.discrete-fourier@1");
}
