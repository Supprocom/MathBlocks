namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class MatrixColumnSumsV1Block
    {
        internal const string Identity = "matrix.column-sums@1";
        internal static MathBlockOperation Create() => CreateMatrixReduction("matrix.column-sums", MathBlockStructure.ColumnSums, [4d, 6d], rows: false);
    }
}
