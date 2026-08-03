namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class MatrixInverseV1Block
    {
        internal const string Identity = "matrix.inverse@1";
        internal static MathBlockOperation Create() => CreateInverse();
        private static MathBlockOperation CreateInverse() => MathBlockOperationFactory.Create("matrix.inverse", 1, InverseType, inputs => MathBlockLinearAlgebra.TryInverse(inputs[0].AsMatrix(), out var inverse) ? MathBlockValue.Matrix(inverse!, inputs[0].Type.Unit.Pow(new MathRational(-1))) : MathBlockValue.Invalid(MathBlockType.Matrix(inputs[0].Type.Unit.Pow(new MathRational(-1)), inputs[0].Type.Rows, inputs[0].Type.Columns), "The matrix is singular."), [MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [2d, 0d, 0d, 4d]))], MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [0.5d, 0d, 0d, 0.25d])), performanceIterations: 4);
    }
}
