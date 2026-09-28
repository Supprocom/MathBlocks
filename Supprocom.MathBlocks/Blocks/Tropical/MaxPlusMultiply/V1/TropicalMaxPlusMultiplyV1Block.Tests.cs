namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>tropical.max-plus-multiply@1</c> operation contract.</summary>
public sealed class TropicalMaxPlusMultiplyV1BlockTests
{
    /// <summary>Checks the <c>tropical.max-plus-multiply@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("tropical.max-plus-multiply@1");
}
