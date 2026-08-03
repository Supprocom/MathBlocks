namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class MatrixTraceV1Block
    {
        internal const string Identity = "matrix.trace@1";
        internal static MathBlockOperation Create() => CreateScalarMatrixReduction("matrix.trace", MathBlockLinearAlgebra.Trace, matrixA, 5d, TraceType);
    }
}
