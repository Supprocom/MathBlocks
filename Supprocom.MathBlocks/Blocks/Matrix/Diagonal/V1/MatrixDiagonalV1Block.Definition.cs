namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class MatrixDiagonalV1Block
    {
        internal const string Identity = "matrix.diagonal@1";
        internal static MathBlockOperation Create() => CreateDiagonal();
        private static MathBlockOperation CreateDiagonal() => MathBlockOperationFactory.Create("matrix.diagonal", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
            var length = types[0].Rows > 0 && types[0].Columns > 0 ? Math.Min(types[0].Rows, types[0].Columns) : 0;
            return MathBlockType.Vector(types[0].Unit, length);
        }, inputs => MathBlockValue.Vector(MathBlockStructure.Diagonal(inputs[0].AsMatrix()), inputs[0].Type.Unit, true), [matrix], MathBlockValue.Vector([1d, 4d]), performanceIterations: 32);
    }
}
