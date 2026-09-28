namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.tangent@1</c> operation contract.</summary>
public sealed class ScalarTangentV1BlockTests
{
    /// <summary>Checks the <c>scalar.tangent@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.tangent@1");
}
