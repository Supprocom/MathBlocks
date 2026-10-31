namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class ShapeIsLogConcaveV1Block
    {
        internal const string Identity = "shape.is-log-concave@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateVectorBoolean("shape.is-log-concave", MathBlockAdvanced.IsLogConcave, MathBlockValue.Vector([1d, 2d, 1d]), true);
    }
}
