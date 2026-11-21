namespace Supprocom.MathBlocks;

internal static partial class MatrixMathBlocks
{
    internal static class MatrixSubtractV1Block
    {
        internal const string Identity = "matrix.subtract@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateBinaryMatrix("matrix.subtract", MathBlockLinearAlgebra.Subtract, new MathBlockMatrix(2, 2, [-1f, 2f, 2f, 2f]), SameMatrices);
    }
}
