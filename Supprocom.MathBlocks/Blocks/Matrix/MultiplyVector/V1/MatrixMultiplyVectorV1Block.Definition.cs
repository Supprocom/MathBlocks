namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class MatrixMultiplyVectorV1Block
    {
        internal const string Identity = "matrix.multiply-vector@1";
        internal static MathBlockOperation Create() => MatrixMultiplyVectorV1BlockCpu.Create();
    }
}
