namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class MatrixDiagonalFromVectorV1Block
    {
        internal const string Identity = "matrix.diagonal-from-vector@1";
        internal static MathBlockOperation Create() => CreateDiagonalMatrix();
        private static MathBlockOperation CreateDiagonalMatrix() => MathBlockOperationFactory.Create("matrix.diagonal-from-vector", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            return MathBlockType.Matrix(types[0].Unit, types[0].Rows, types[0].Rows);
        }, inputs => inputs[0].AsVector().Count > 0 ? MathBlockValue.Matrix(MathBlockStructure.DiagonalMatrix(inputs[0].AsVector()), inputs[0].Type.Unit) : MathBlockValue.Invalid(MathBlockType.Matrix(inputs[0].Type.Unit), "The vector is empty."), [MathBlockValue.Vector([1d, 2d])], MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [1d, 0d, 0d, 2d])), performanceIterations: 16);
    }
}
