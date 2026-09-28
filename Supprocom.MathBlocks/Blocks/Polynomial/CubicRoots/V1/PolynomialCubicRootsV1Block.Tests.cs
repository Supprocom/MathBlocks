namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>polynomial.cubic-roots@1</c> operation contract.</summary>
public sealed class PolynomialCubicRootsV1BlockTests
{
    /// <summary>Checks the <c>polynomial.cubic-roots@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("polynomial.cubic-roots@1");
}
