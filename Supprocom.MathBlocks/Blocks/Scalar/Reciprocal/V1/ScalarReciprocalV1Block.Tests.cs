namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.reciprocal@1</c> operation contract.</summary>
public sealed class ScalarReciprocalV1BlockTests
{
    /// <summary>Checks the <c>scalar.reciprocal@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.reciprocal@1");
}
