namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class MatrixAppendRowV1Block
    {
        internal const string Identity = "matrix.append-row@1";
        internal static MathBlockOperation Create() => CreateAppendRow();
        private static MathBlockOperation CreateAppendRow() => MathBlockOperationFactory.Create("matrix.append-row", 2, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Vector);
            if (types[0].Unit != types[1].Unit || types[0].Columns != 0 && types[1].Rows != 0 && types[0].Columns != types[1].Rows)
                throw new InvalidOperationException("The matrix and row must have compatible types.");
            return MathBlockType.Matrix(types[0].Unit, types[0].Rows == 0 ? 0 : types[0].Rows + 1, types[0].Columns);
        }, inputs => MathBlockValue.Matrix(MathBlockStructure.AppendRow(inputs[0].AsMatrix(), inputs[1].AsVector()), inputs[0].Type.Unit), [matrix, MathBlockValue.Vector([5d, 6d])], MathBlockValue.Matrix(new MathBlockMatrix(3, 2, [1d, 2d, 3d, 4d, 5d, 6d])), performanceIterations: 16);
    }
}
