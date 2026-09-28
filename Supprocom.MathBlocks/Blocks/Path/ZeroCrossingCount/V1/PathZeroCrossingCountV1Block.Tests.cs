namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>path.zero-crossing-count@1</c> operation contract.</summary>
public sealed class PathZeroCrossingCountV1BlockTests
{
    /// <summary>Checks the <c>path.zero-crossing-count@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("path.zero-crossing-count@1");
}
