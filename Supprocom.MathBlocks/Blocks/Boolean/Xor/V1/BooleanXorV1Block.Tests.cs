namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>boolean.xor@1</c> operation contract.</summary>
public sealed class BooleanXorV1BlockTests
{
    /// <summary>Checks the <c>boolean.xor@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("boolean.xor@1");
}
