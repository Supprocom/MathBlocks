namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class MatrixLargestSymmetricEigenvalueV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateScalarMatrixReduction("matrix.largest-symmetric-eigenvalue", value => MathBlockLinearAlgebra.SymmetricEigenvalues(value)[^1], symmetric, 3d, TraceType);
    }
}
