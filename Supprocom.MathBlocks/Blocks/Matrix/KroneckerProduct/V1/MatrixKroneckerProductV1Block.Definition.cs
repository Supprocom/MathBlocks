namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class MatrixKroneckerProductV1Block
    {
        internal const string Identity = "matrix.kronecker-product@1";
        internal static MathBlockOperation Create() => CreateKronecker();
        private static MathBlockOperation CreateKronecker() => MathBlockOperationFactory.Create("matrix.kronecker-product", 2, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Matrix);
            return MathBlockType.Matrix(types[0].Unit.Multiply(types[1].Unit), ProductOrUnknown(types[0].Rows, types[1].Rows), ProductOrUnknown(types[0].Columns, types[1].Columns));
        }, inputs => MathBlockValue.Matrix(MathBlockStructure.KroneckerProduct(inputs[0].AsMatrix(), inputs[1].AsMatrix()), inputs[0].Type.Unit.Multiply(inputs[1].Type.Unit)), [MathBlockValue.Matrix(new MathBlockMatrix(1, 2, [1d, 2d])), MathBlockValue.Matrix(new MathBlockMatrix(2, 1, [3d, 4d]))], MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [3d, 6d, 4d, 8d])), performanceIterations: 8);
    }
}
