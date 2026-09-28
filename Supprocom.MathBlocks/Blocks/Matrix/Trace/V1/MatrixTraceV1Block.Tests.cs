namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.trace@1</c> operation contract.</summary>
public sealed class MatrixTraceV1BlockTests
{
    /// <summary>Checks the <c>matrix.trace@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.trace@1");
}
