namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>boolean-vector.or@1</c> operation contract.</summary>
public sealed class BooleanVectorOrV1BlockTests
{
    /// <summary>Checks the <c>boolean-vector.or@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("boolean-vector.or@1");
}
