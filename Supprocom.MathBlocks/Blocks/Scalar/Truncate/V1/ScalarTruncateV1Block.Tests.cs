namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.truncate@1</c> operation contract.</summary>
public sealed class ScalarTruncateV1BlockTests
{
    /// <summary>Checks the <c>scalar.truncate@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.truncate@1");
}
