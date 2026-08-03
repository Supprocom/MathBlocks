namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class ShapeGreatestConvexMinorantV1Block
    {
        internal const string Identity = "shape.greatest-convex-minorant@1";
        internal static MathBlockOperation Create() => CreateVectorUnary("shape.greatest-convex-minorant", MathBlockAdvanced.GreatestConvexMinorant, MathBlockValue.Vector([0d, 2d, 2d]), [0d, 1d, 2d], SameVector);
    }
}
