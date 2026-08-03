namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class MatrixSubtractV1Block
    {
        internal const string Identity = "matrix.subtract@1";
        internal static MathBlockOperation Create() => CreateBinaryMatrix("matrix.subtract", MathBlockLinearAlgebra.Subtract, new MathBlockMatrix(2, 2, [-1d, 2d, 2d, 2d]), SameMatrices);
    }
}
