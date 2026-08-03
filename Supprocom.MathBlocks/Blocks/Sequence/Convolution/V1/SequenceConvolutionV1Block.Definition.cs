namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class SequenceConvolutionV1Block
    {
        internal const string Identity = "sequence.convolution@1";
        internal static MathBlockOperation Create() => CreateConvolution();
        private static MathBlockOperation CreateConvolution() => MathBlockOperationFactory.Create("sequence.convolution", 2, ConvolutionType, inputs => MathBlockValue.Vector(MathBlockVectorMath.Convolution(inputs[0].AsVector(), inputs[1].AsVector()), inputs[0].Type.Unit.Multiply(inputs[1].Type.Unit), true), [MathBlockValue.Vector([1d, 2d]), MathBlockValue.Vector([1d, 1d])], MathBlockValue.Vector([1d, 3d, 2d]), performanceIterations: 32);
    }
}
