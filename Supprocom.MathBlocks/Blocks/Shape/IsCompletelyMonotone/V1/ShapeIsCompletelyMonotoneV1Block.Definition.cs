namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class ShapeIsCompletelyMonotoneV1Block
    {
        internal const string Identity = "shape.is-completely-monotone@1";
        internal static MathBlockOperation Create() => CreateVectorBoolean("shape.is-completely-monotone", MathBlockAdvanced.IsCompletelyMonotone, MathBlockValue.Vector([1d, 0.5d, 0.25d]), true);
    }
}
