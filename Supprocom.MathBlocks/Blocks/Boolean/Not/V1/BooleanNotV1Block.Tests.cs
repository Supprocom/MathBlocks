namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>boolean.not@1</c> operation contract.</summary>
public sealed class BooleanNotV1BlockTests
{
    /// <summary>Checks the <c>boolean.not@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("boolean.not@1");
}
