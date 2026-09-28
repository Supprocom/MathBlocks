namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.square-root@1</c> operation contract.</summary>
public sealed class VectorSquareRootV1BlockTests
{
    /// <summary>Checks the <c>vector.square-root@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.square-root@1");
}
