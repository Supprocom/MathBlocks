namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class MatrixToeplitzV1Block
    {
        internal const string Identity = "matrix.toeplitz@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateStructuredMatrix("matrix.toeplitz", MathBlockAdvanced.Toeplitz, MathBlockValue.Vector([1f, 2f]), MathBlockValue.Vector([1f, 3f, 4f]), new MathBlockMatrix(2, 3, [1f, 3f, 4f, 2f, 1f, 3f]));
    }
}
