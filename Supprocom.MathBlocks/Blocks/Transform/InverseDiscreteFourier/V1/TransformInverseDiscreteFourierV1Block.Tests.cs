namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>transform.inverse-discrete-fourier@1</c> operation contract.</summary>
public sealed class TransformInverseDiscreteFourierV1BlockTests
{
    /// <summary>Checks the <c>transform.inverse-discrete-fourier@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("transform.inverse-discrete-fourier@1");
}
