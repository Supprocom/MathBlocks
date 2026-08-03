namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class MatrixSmallestSymmetricEigenvalueV1Block
    {
        internal const string Identity = "matrix.smallest-symmetric-eigenvalue@1";
        internal static MathBlockOperation Create() => MatrixSmallestSymmetricEigenvalueV1BlockCpu.Create();
    }
}
