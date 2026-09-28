namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>polynomial.elementary-symmetric@1</c> operation contract.</summary>
public sealed class PolynomialElementarySymmetricV1BlockTests
{
    /// <summary>Checks the <c>polynomial.elementary-symmetric@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("polynomial.elementary-symmetric@1");
}
