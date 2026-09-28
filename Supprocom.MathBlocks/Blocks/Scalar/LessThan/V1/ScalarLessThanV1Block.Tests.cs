namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.less-than@1</c> operation contract.</summary>
public sealed class ScalarLessThanV1BlockTests
{
    /// <summary>Checks the <c>scalar.less-than@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.less-than@1");
}
