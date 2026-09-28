namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>extension.mcshane@1</c> operation contract.</summary>
public sealed class ExtensionMcshaneV1BlockTests
{
    /// <summary>Checks the <c>extension.mcshane@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("extension.mcshane@1");
}
