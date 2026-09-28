namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.stack-rows@1</c> operation contract.</summary>
public sealed class MatrixStackRowsV1BlockTests
{
    /// <summary>Checks the <c>matrix.stack-rows@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.stack-rows@1");
}
