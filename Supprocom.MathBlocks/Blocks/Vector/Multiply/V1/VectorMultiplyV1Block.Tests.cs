namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.multiply@1</c> operation contract.</summary>
public sealed class VectorMultiplyV1BlockTests
{
    /// <summary>Checks the <c>vector.multiply@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.multiply@1");
}
