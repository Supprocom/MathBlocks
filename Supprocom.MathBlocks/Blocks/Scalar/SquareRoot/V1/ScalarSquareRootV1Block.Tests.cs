namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.square-root@1</c> operation contract.</summary>
public sealed class ScalarSquareRootV1BlockTests
{
    /// <summary>Checks the <c>scalar.square-root@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.square-root@1");
}
