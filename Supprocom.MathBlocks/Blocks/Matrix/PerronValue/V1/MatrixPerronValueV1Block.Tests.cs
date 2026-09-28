namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.perron-value@1</c> operation contract.</summary>
public sealed class MatrixPerronValueV1BlockTests
{
    /// <summary>Checks the <c>matrix.perron-value@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.perron-value@1");
}
