namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class MatrixFrobeniusNormV1Block
    {
        internal const string Identity = "matrix.frobenius-norm@1";
        internal static MathBlockOperation Create() => CreateScalarMatrixReduction("matrix.frobenius-norm", MathBlockLinearAlgebra.FrobeniusNorm, matrixA, Math.Sqrt(30d), TraceType);
    }
}
