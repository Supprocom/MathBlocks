namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class MatrixGramV1Block
    {
        internal const string Identity = "matrix.gram@1";
        internal static MathBlockOperation Create() => CreateUnaryMatrix("matrix.gram", MathBlockLinearAlgebra.Gram, new MathBlockMatrix(2, 2, [10d, 14d, 14d, 20d]), GramType);
    }
}
