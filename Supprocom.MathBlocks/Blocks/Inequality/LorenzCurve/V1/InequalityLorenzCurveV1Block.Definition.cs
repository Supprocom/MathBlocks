namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class InequalityLorenzCurveV1Block
    {
        internal const string Identity = "inequality.lorenz-curve@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateVectorUnary("inequality.lorenz-curve", MathBlockAdvanced.LorenzCurve, MathBlockValue.Vector([1d, 3d]), [0d, 0.25d, 1d], DimensionlessVectorOutput);
    }
}
