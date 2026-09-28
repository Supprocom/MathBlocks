namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>boolean-vector.and@1</c> operation contract.</summary>
public sealed class BooleanVectorAndV1BlockTests
{
    /// <summary>Checks the <c>boolean-vector.and@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("boolean-vector.and@1");
}
