namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class MatrixSchurComplementV1Block
    {
        internal const string Identity = "matrix.schur-complement@1";
        internal static MathBlockOperation Create() => CreateSchurComplement();
        private static MathBlockOperation CreateSchurComplement() => MathBlockOperationFactory.Create("matrix.schur-complement", 2, types =>
        {
            RequireSquareMatrix(types[0]);
            RequireDimensionlessScalar(types[1]);
            return MathBlockType.Matrix(types[0].Unit);
        }, inputs => TryInteger(inputs[1].AsScalar(), out var size) && size > 0 && size < inputs[0].AsMatrix().Rows ? MathBlockValue.Matrix(MathBlockAdvanced.SchurComplement(inputs[0].AsMatrix(), size), inputs[0].Type.Unit) : MathBlockValue.Invalid(MathBlockType.Matrix(inputs[0].Type.Unit), "The retained size is outside the operation domain."), [MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [3d, 1d, 1d, 1d])), MathBlockValue.Scalar(1d)], MathBlockValue.Matrix(new MathBlockMatrix(1, 1, [2d])), performanceIterations: 4);
    }
}
