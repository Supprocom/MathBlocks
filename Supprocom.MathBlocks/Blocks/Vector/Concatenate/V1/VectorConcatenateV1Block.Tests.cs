namespace Supprocom.MathBlocks.Tests;

public sealed class VectorConcatenateV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("vector.concatenate@1");

    [Fact]
    public void CPU_worker_concatenates_unequal_vector_lengths()
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
