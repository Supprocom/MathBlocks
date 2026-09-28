namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.append@1</c> operation contract.</summary>
public sealed class VectorAppendV1BlockTests
{
    /// <summary>Checks the <c>vector.append@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.append@1");
}
