namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class OrderIsotonicRegressionV1Block
    {
        internal const string Identity = "order.isotonic-regression@1";
        internal static MathBlockOperation Create() => CreateVectorUnary("order.isotonic-regression", MathBlockAdvanced.IsotonicRegression, MathBlockValue.Vector([3d, 1d, 2d]), [2d, 2d, 2d], SameVector);
    }
}
