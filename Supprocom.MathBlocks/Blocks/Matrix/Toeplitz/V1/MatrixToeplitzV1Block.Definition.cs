namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class MatrixToeplitzV1Block
    {
        internal const string Identity = "matrix.toeplitz@1";
        internal static MathBlockOperation Create() => CreateStructuredMatrix("matrix.toeplitz", MathBlockAdvanced.Toeplitz, MathBlockValue.Vector([1d, 2d]), MathBlockValue.Vector([1d, 3d, 4d]), new MathBlockMatrix(2, 3, [1d, 3d, 4d, 2d, 1d, 3d]));
    }
}
