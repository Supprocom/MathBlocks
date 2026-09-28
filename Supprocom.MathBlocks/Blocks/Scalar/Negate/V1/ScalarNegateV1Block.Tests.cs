namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.negate@1</c> operation contract.</summary>
public sealed class ScalarNegateV1BlockTests
{
    /// <summary>Checks the <c>scalar.negate@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.negate@1");
}
