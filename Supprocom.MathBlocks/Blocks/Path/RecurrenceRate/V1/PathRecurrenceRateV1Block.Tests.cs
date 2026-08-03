namespace Supprocom.MathBlocks.Tests;

public sealed class PathRecurrenceRateV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("path.recurrence-rate@1");
}
