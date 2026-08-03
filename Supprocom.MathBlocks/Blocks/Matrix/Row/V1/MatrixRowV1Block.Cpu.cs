namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class MatrixRowV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateMatrixIndex("matrix.row", row: true);
    }
}
