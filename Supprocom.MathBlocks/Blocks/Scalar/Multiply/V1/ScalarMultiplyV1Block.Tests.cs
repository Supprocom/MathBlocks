namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.multiply@1</c> operation contract.</summary>
public sealed class ScalarMultiplyV1BlockTests
{
    /// <summary>Checks the <c>scalar.multiply@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.multiply@1");
}
