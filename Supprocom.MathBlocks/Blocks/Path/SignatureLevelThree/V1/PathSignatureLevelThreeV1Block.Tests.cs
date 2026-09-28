namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>path.signature-level-three@1</c> operation contract.</summary>
public sealed class PathSignatureLevelThreeV1BlockTests
{
    /// <summary>Checks the <c>path.signature-level-three@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("path.signature-level-three@1");
}
