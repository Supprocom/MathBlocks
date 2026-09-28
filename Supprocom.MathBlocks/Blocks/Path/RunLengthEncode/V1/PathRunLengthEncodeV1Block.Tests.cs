namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>path.run-length-encode@1</c> operation contract.</summary>
public sealed class PathRunLengthEncodeV1BlockTests
{
    /// <summary>Checks the <c>path.run-length-encode@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("path.run-length-encode@1");
}
