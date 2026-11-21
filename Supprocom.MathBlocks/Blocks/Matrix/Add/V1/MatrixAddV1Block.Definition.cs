namespace Supprocom.MathBlocks;

internal static partial class MatrixMathBlocks
{
    internal static class MatrixAddV1Block
    {
        internal const string Identity = "matrix.add@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateBinaryMatrix("matrix.add", MathBlockLinearAlgebra.Add, new MathBlockMatrix(2, 2, [3f, 2f, 4f, 6f]), SameMatrices);
    }
}
