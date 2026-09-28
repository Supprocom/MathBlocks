namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>order.majorizes@1</c> operation contract.</summary>
public sealed class OrderMajorizesV1BlockTests
{
    /// <summary>Checks the <c>order.majorizes@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("order.majorizes@1");
}
