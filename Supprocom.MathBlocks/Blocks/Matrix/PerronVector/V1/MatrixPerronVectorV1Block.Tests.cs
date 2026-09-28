namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.perron-vector@1</c> operation contract.</summary>
public sealed class MatrixPerronVectorV1BlockTests
{
    /// <summary>Checks the <c>matrix.perron-vector@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.perron-vector@1");
}
