namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>sequence.lead@1</c> operation contract.</summary>
public sealed class SequenceLeadV1BlockTests
{
    /// <summary>Checks the <c>sequence.lead@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("sequence.lead@1");
}
