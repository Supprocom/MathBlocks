namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.less-than@1</c> operation contract.</summary>
public sealed class VectorLessThanV1BlockTests
{
    /// <summary>Checks the <c>vector.less-than@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.less-than@1");
}
