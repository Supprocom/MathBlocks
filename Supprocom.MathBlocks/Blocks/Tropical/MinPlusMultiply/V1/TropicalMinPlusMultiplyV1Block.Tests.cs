namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>tropical.min-plus-multiply@1</c> operation contract.</summary>
public sealed class TropicalMinPlusMultiplyV1BlockTests
{
    /// <summary>Checks the <c>tropical.min-plus-multiply@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("tropical.min-plus-multiply@1");
}
