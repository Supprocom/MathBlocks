namespace Supprocom.MathBlocks.Tests;

public sealed class ComplexVectorMagnitudeV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("complex-vector.magnitude@1");
}
