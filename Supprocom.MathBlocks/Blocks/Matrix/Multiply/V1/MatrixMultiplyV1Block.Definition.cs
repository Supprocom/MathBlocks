namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class MatrixMultiplyV1Block
    {
        internal const string Identity = "matrix.multiply@1";
        internal static MathBlockOperation Create() => MatrixMultiplyV1BlockCpu.Create();
    }
}
