namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>boolean-vector.all@1</c> operation contract.</summary>
public sealed class BooleanVectorAllV1BlockTests
{
    /// <summary>Checks the <c>boolean-vector.all@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("boolean-vector.all@1");
}
