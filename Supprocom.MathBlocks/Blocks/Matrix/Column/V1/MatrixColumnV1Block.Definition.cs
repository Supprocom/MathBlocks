namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class MatrixColumnV1Block
    {
        internal const string Identity = "matrix.column@1";
        internal static MathBlockOperation Create() => MatrixColumnV1BlockCpu.Create();
    }
}
