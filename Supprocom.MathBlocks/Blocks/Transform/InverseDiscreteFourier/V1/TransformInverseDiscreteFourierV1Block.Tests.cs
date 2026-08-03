namespace Supprocom.MathBlocks.Tests;

public sealed class TransformInverseDiscreteFourierV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("transform.inverse-discrete-fourier@1");
}
