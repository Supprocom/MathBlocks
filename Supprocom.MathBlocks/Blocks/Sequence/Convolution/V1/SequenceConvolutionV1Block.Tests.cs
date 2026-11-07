namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>sequence.convolution@1</c> operation contract.</summary>
public sealed class SequenceConvolutionV1BlockTests
{
    /// <summary>Checks the <c>sequence.convolution@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("sequence.convolution@1");

    /// <summary>Checks that an empty operand gives an invalid vector, as on CUDA, and never an exception or a valid vector.</summary>
    [Theory]
    [Trait("Category", "BlockContract")]
    [InlineData(0, 3)]
    [InlineData(3, 0)]
    [InlineData(0, 1)]
    [InlineData(1, 0)]
    [InlineData(0, 0)]
    public void EmptyOperandIsInvalid(int leftCount, int rightCount)
    {
        var operation = MathBlockCatalog.Standard.Get("sequence.convolution@1");
        var result = operation.Evaluate([
            MathBlockValue.Vector(new double[leftCount]),
            MathBlockValue.Vector(new double[rightCount])]);
        Assert.False(result.IsValid);
        Assert.Equal(MathBlockValueKind.Vector, result.Type.Kind);
    }

    /// <summary>Checks that non-empty operands still give the full convolution.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void NonEmptyOperandsGiveTheFullConvolution()
    {
        var result = MathBlockCatalog.Standard.Get("sequence.convolution@1")
            .Evaluate([MathBlockValue.Vector([1d, 2d]), MathBlockValue.Vector([1d, 1d, -0d])]);
        Assert.True(result.IsValid);
        Assert.Equal([1d, 3d, 2d, -0d], result.AsVector().ToArray());
    }
}
