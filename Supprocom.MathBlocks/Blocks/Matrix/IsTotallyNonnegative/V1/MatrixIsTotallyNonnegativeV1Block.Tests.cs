namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.is-totally-nonnegative@1</c> operation contract.</summary>
public sealed class MatrixIsTotallyNonnegativeV1BlockTests
{
    /// <summary>Checks the <c>matrix.is-totally-nonnegative@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.is-totally-nonnegative@1");
}
