namespace Supprocom.MathBlocks;

internal static partial class MatrixMathBlocks
{
    internal static class MatrixLargestSymmetricEigenvalueV1Block
    {
        internal const string Identity = "matrix.largest-symmetric-eigenvalue@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => MatrixLargestSymmetricEigenvalueV1BlockCpu.Create();
    }
}
