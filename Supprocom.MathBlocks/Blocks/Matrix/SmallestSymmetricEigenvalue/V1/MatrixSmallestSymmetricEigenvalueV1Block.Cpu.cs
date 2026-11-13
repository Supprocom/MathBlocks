namespace Supprocom.MathBlocks;

internal static partial class MatrixMathBlocks
{
    internal static class MatrixSmallestSymmetricEigenvalueV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateEigenvalueReduction("matrix.smallest-symmetric-eigenvalue", values => values[0], symmetric, 1d, TraceType);
    }
}
