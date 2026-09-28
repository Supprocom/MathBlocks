namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>inequality.gini-coefficient@1</c> operation contract.</summary>
public sealed class InequalityGiniCoefficientV1BlockTests
{
    /// <summary>Checks the <c>inequality.gini-coefficient@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("inequality.gini-coefficient@1");
}
