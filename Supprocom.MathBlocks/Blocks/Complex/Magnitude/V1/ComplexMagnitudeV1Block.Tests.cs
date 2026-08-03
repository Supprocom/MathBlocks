namespace Supprocom.MathBlocks.Tests;

public sealed class ComplexMagnitudeV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("complex.magnitude@1");
}
