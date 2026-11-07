namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class SequenceConvolutionV1Block
    {
        internal const string Identity = "sequence.convolution@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Expanding;
        internal static MathBlockOperation Create() => CreateConvolution();
        private static MathBlockOperation CreateConvolution() => MathBlockOperationFactory.Create("sequence.convolution", 2, ConvolutionType, inputs =>
        {
            // An empty operand is outside the domain, as for the other vector operations and as on CUDA (an empty vector has no convolution).
            var unit = inputs[0].Type.Unit.Multiply(inputs[1].Type.Unit);
            return inputs[0].AsVector().Count > 0 && inputs[1].AsVector().Count > 0
                ? MathBlockValue.Vector(MathBlockVectorMath.Convolution(inputs[0].AsVector(), inputs[1].AsVector()), unit, true)
                : MathBlockValue.Invalid(MathBlockType.Vector(unit), "The vector is empty.");
        }, [MathBlockValue.Vector([1d, 2d]), MathBlockValue.Vector([1d, 1d])], MathBlockValue.Vector([1d, 3d, 2d]), performanceIterations: 32);
    }
}
