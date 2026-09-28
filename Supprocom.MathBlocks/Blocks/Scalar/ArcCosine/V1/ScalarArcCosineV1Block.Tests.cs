namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.arc-cosine@1</c> operation contract.</summary>
public sealed class ScalarArcCosineV1BlockTests
{
    /// <summary>Checks the <c>scalar.arc-cosine@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.arc-cosine@1");
}
