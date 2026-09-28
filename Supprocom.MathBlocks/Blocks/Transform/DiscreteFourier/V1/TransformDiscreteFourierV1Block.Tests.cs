namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>transform.discrete-fourier@1</c> operation contract.</summary>
public sealed class TransformDiscreteFourierV1BlockTests
{
    /// <summary>Checks the <c>transform.discrete-fourier@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("transform.discrete-fourier@1");
}
