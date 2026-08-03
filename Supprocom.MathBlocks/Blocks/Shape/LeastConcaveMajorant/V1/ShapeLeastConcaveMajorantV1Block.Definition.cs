namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class ShapeLeastConcaveMajorantV1Block
    {
        internal const string Identity = "shape.least-concave-majorant@1";
        internal static MathBlockOperation Create() => CreateVectorUnary("shape.least-concave-majorant", MathBlockAdvanced.LeastConcaveMajorant, MathBlockValue.Vector([0d, 0d, 2d]), [0d, 1d, 2d], SameVector);
    }
}
