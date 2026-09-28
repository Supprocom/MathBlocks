namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>sequence.convolution@1</c> operation contract.</summary>
public sealed class SequenceConvolutionV1BlockTests
{
    /// <summary>Checks the <c>sequence.convolution@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("sequence.convolution@1");
}
