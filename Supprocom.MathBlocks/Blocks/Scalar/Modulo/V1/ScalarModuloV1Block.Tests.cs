namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.modulo@1</c> operation contract.</summary>
public sealed class ScalarModuloV1BlockTests
{
    /// <summary>Checks the <c>scalar.modulo@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.modulo@1");
}
