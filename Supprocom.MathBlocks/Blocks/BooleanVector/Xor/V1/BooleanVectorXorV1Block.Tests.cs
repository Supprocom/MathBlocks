namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>boolean-vector.xor@1</c> operation contract.</summary>
public sealed class BooleanVectorXorV1BlockTests
{
    /// <summary>Checks the <c>boolean-vector.xor@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("boolean-vector.xor@1");
}
