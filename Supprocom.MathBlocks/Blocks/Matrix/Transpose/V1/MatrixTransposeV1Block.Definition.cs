namespace Supprocom.MathBlocks;

internal static partial class MatrixMathBlocks
{
    internal static class MatrixTransposeV1Block
    {
        internal const string Identity = "matrix.transpose@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateUnaryMatrix("matrix.transpose", MathBlockLinearAlgebra.Transpose, new MathBlockMatrix(2, 2, [1f, 3f, 2f, 4f]), TransposeType);
    }
}
