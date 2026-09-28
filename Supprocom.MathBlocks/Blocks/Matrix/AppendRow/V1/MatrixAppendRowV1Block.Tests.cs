namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.append-row@1</c> operation contract.</summary>
public sealed class MatrixAppendRowV1BlockTests
{
    /// <summary>Checks the <c>matrix.append-row@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.append-row@1");
}
