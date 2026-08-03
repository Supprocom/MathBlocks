namespace Supprocom.MathBlocks.Tests;

public sealed class ProjectiveHilbertDistanceV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("projective.hilbert-distance@1");
}
