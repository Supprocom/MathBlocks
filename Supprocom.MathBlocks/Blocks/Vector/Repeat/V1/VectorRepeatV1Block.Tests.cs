namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.repeat@1</c> operation contract.</summary>
public sealed class VectorRepeatV1BlockTests
{
    /// <summary>Checks the <c>vector.repeat@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.repeat@1");
}
