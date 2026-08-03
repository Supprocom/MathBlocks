namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class MatrixRankV1Block
    {
        internal const string Identity = "matrix.rank@1";
        internal static MathBlockOperation Create() => CreateScalarMatrixReduction("matrix.rank", value => MathBlockLinearAlgebra.Rank(value), matrixA, 2d, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
            return MathBlockType.Scalar();
        });
    }
}
