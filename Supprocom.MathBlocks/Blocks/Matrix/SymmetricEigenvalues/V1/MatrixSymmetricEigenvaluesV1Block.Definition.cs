namespace Supprocom.MathBlocks;

internal static partial class MatrixMathBlocks
{
    internal static class MatrixSymmetricEigenvaluesV1Block
    {
        internal const string Identity = "matrix.symmetric-eigenvalues@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => MatrixSymmetricEigenvaluesV1BlockCpu.Create();
    }
}
