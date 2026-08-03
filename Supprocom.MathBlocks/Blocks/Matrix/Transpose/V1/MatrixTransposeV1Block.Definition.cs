namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class MatrixTransposeV1Block
    {
        internal const string Identity = "matrix.transpose@1";
        internal static MathBlockOperation Create() => CreateUnaryMatrix("matrix.transpose", MathBlockLinearAlgebra.Transpose, new MathBlockMatrix(2, 2, [1d, 3d, 2d, 4d]), TransposeType);
    }
}
