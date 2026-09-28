namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>probability.softmax@1</c> operation contract.</summary>
public sealed class ProbabilitySoftmaxV1BlockTests
{
    /// <summary>Checks the <c>probability.softmax@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("probability.softmax@1");
}
