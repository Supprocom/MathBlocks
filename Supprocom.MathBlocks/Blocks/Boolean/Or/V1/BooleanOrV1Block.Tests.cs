namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>boolean.or@1</c> operation contract.</summary>
public sealed class BooleanOrV1BlockTests
{
    /// <summary>Checks the <c>boolean.or@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("boolean.or@1");
}
