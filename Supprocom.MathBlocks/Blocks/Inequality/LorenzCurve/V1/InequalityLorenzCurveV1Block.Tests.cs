namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>inequality.lorenz-curve@1</c> operation contract.</summary>
public sealed class InequalityLorenzCurveV1BlockTests
{
    /// <summary>Checks the <c>inequality.lorenz-curve@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("inequality.lorenz-curve@1");
}
