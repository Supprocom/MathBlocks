namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class MatrixSmallestSymmetricEigenvalueV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateScalarMatrixReduction("matrix.smallest-symmetric-eigenvalue", value => MathBlockLinearAlgebra.SymmetricEigenvalues(value)[0], symmetric, 1d, TraceType);
    }
}
