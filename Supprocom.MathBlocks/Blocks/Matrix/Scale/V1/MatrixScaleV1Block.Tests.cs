namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.scale@1</c> operation contract.</summary>
public sealed class MatrixScaleV1BlockTests
{
    /// <summary>Checks the <c>matrix.scale@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.scale@1");
}
