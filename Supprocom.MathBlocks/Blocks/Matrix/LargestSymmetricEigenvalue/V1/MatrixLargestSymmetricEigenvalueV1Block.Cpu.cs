namespace Supprocom.MathBlocks;

internal static partial class MatrixMathBlocks
{
    internal static class MatrixLargestSymmetricEigenvalueV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateEigenvalueReduction("matrix.largest-symmetric-eigenvalue", values => values[^1], symmetric, 3d, TraceType);
    }
}
