namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class ShapeIsCompletelyMonotoneV1Block
    {
        internal const string Identity = "shape.is-completely-monotone@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateVectorBoolean("shape.is-completely-monotone", MathBlockAdvanced.IsCompletelyMonotone, MathBlockValue.Vector([1f, 0.5f, 0.25f]), true);
    }
}
