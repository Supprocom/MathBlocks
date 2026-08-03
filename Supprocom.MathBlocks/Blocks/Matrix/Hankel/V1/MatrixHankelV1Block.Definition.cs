namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class MatrixHankelV1Block
    {
        internal const string Identity = "matrix.hankel@1";
        internal static MathBlockOperation Create() => CreateStructuredMatrix("matrix.hankel", MathBlockAdvanced.Hankel, MathBlockValue.Vector([1d, 2d]), MathBlockValue.Vector([2d, 3d, 4d]), new MathBlockMatrix(2, 3, [1d, 2d, 3d, 2d, 3d, 4d]));
    }
}
