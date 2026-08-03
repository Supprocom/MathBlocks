namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class MatrixColumnV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateMatrixIndex("matrix.column", row: false);
    }
}
