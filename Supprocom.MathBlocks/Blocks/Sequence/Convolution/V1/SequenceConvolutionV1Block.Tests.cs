namespace Supprocom.MathBlocks.Tests;

public sealed class SequenceConvolutionV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("sequence.convolution@1");
}
