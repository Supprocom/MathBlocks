namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class ShapeGreatestConvexMinorantV1Block
    {
        internal const string Identity = "shape.greatest-convex-minorant@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateVectorUnary("shape.greatest-convex-minorant", MathBlockAdvanced.GreatestConvexMinorant, MathBlockValue.Vector([0f, 2f, 2f]), [0f, 1f, 2f], SameVector);
    }
}
