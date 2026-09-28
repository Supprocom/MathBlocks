namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.cosine@1</c> operation contract.</summary>
public sealed class ScalarCosineV1BlockTests
{
    /// <summary>Checks the <c>scalar.cosine@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.cosine@1");
}
