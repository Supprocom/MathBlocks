namespace Supprocom.MathBlocks;

internal static partial class MatrixMathBlocks
{
    internal static class MatrixScaleV1Block
    {
        internal const string Identity = "matrix.scale@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateScale();
        private static MathBlockOperation CreateScale() => MathBlockOperationFactory.Create("matrix.scale", 2, MatrixScaleType, inputs => MathBlockValue.Matrix(MathBlockLinearAlgebra.Scale(inputs[0].AsMatrix(), inputs[1].AsScalar()), inputs[0].Type.Unit.Multiply(inputs[1].Type.Unit)), [matrixA, MathBlockValue.Scalar(2f)], MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [2f, 4f, 6f, 8f])), performanceIterations: 8);
    }
}
