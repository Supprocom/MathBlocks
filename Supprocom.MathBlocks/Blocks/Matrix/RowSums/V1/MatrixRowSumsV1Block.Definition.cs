namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class MatrixRowSumsV1Block
    {
        internal const string Identity = "matrix.row-sums@1";
        internal static MathBlockOperation Create() => CreateMatrixReduction("matrix.row-sums", MathBlockStructure.RowSums, [3d, 7d], rows: true);
    }
}
