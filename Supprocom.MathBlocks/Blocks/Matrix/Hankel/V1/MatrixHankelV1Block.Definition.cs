namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class MatrixHankelV1Block
    {
        internal const string Identity = "matrix.hankel@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Forward;
        internal static MathBlockOperation Create() => CreateStructuredMatrix("matrix.hankel", MathBlockAdvanced.Hankel, MathBlockValue.Vector([1f, 2f]), MathBlockValue.Vector([2f, 3f, 4f]), new MathBlockMatrix(2, 3, [1f, 2f, 3f, 2f, 3f, 4f]));
    }
}
