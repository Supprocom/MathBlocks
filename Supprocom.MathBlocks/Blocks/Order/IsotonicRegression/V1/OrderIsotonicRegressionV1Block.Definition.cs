namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class OrderIsotonicRegressionV1Block
    {
        internal const string Identity = "order.isotonic-regression@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateVectorUnary("order.isotonic-regression", MathBlockAdvanced.IsotonicRegression, MathBlockValue.Vector([3f, 1f, 2f]), [2f, 2f, 2f], SameVector);
    }
}
