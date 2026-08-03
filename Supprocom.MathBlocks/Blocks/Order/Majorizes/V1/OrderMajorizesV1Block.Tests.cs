namespace Supprocom.MathBlocks.Tests;

public sealed class OrderMajorizesV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("order.majorizes@1");
}
