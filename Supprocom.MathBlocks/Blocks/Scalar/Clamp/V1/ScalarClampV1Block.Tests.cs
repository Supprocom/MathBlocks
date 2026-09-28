namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.clamp@1</c> operation contract.</summary>
public sealed class ScalarClampV1BlockTests
{
    /// <summary>Checks the <c>scalar.clamp@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.clamp@1");
}
