namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>complex.square-root@1</c> operation contract.</summary>
public sealed class ComplexSquareRootV1BlockTests
{
    /// <summary>Checks the <c>complex.square-root@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("complex.square-root@1");
}
