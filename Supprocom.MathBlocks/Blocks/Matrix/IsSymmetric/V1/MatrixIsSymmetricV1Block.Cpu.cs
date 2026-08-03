namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class MatrixIsSymmetricV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateBooleanMatrix("matrix.is-symmetric", MathBlockLinearAlgebra.IsSymmetric, symmetric, true);
    }
}
