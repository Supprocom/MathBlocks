namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class MatrixAddV1Block
    {
        internal const string Identity = "matrix.add@1";
        internal static MathBlockOperation Create() => CreateBinaryMatrix("matrix.add", MathBlockLinearAlgebra.Add, new MathBlockMatrix(2, 2, [3d, 2d, 4d, 6d]), SameMatrices);
    }
}
