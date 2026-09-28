namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>path.turning-point-count@1</c> operation contract.</summary>
public sealed class PathTurningPointCountV1BlockTests
{
    /// <summary>Checks the <c>path.turning-point-count@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("path.turning-point-count@1");
}
