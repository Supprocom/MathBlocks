namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>path.signature-level-two@1</c> operation contract.</summary>
public sealed class PathSignatureLevelTwoV1BlockTests
{
    /// <summary>Checks the <c>path.signature-level-two@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("path.signature-level-two@1");
}
