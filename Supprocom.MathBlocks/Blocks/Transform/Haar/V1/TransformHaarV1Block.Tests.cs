namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>transform.haar@1</c> operation contract.</summary>
public sealed class TransformHaarV1BlockTests
{
    /// <summary>Checks the <c>transform.haar@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("transform.haar@1");
}
