namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>path.recurrence-rate@1</c> operation contract.</summary>
public sealed class PathRecurrenceRateV1BlockTests
{
    /// <summary>Checks the <c>path.recurrence-rate@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("path.recurrence-rate@1");
}
