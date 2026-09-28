namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.concatenate@1</c> operation contract.</summary>
public sealed class VectorConcatenateV1BlockTests
{
    /// <summary>Checks the <c>vector.concatenate@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.concatenate@1");

    /// <summary>Checks the <c>vector.concatenate@1</c> operation contract.</summary>
    [Fact]
    public void CPUWorkerConcatenatesUnequalVectorLengths()
    {
        var leftValue = MathBlockValue.Vector([1d, 2d, 3d]);
        var rightValue = MathBlockValue.Vector([4d]);
        var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["left"] = leftValue,
            ["right"] = rightValue
        };
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var left = builder.Input("left", leftValue.Type);
        var right = builder.Input("right", rightValue.Type);
        var concatenated = builder.Apply("vector.concatenate", inputs: [left, right]);
        var program = builder.Output("result", concatenated).Build();

        var result = program.Evaluate(inputs)["result"];

        Assert.True(result.IsValid);
        Assert.Equal(4, result.AsVector().Count);
        Assert.Equal([1d, 2d, 3d, 4d], result.AsVector());
    }
}
