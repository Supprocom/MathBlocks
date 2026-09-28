namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.hyperbolic-cosine@1</c> operation contract.</summary>
public sealed class ScalarHyperbolicCosineV1BlockTests
{
    /// <summary>Checks the <c>scalar.hyperbolic-cosine@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.hyperbolic-cosine@1");
}
