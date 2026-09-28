namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.length@1</c> operation contract.</summary>
public sealed class VectorLengthV1BlockTests
{
    /// <summary>Checks the <c>vector.length@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.length@1");
}
