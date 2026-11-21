namespace Supprocom.MathBlocks;

internal static partial class MatrixMathBlocks
{
    internal static class MatrixMultiplyV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateBinaryMatrix("matrix.multiply", MathBlockLinearAlgebra.Multiply, new MathBlockMatrix(2, 2, [4f, 4f, 10f, 8f]), MultiplyType);
    }
}
