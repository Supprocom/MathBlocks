namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class MatrixHadamardProductV1Block
    {
        internal const string Identity = "matrix.hadamard-product@1";
        internal static MathBlockOperation Create() => CreateBinaryMatrix("matrix.hadamard-product", MathBlockLinearAlgebra.HadamardProduct, new MathBlockMatrix(2, 2, [2d, 0d, 3d, 8d]), HadamardType);
    }
}
