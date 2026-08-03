namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class PathZeroCrossingCountV1Block
    {
        internal const string Identity = "path.zero-crossing-count@1";
        internal static MathBlockOperation Create() => CreatePathScalar("path.zero-crossing-count", values => MathBlockPath.ZeroCrossingCount(values), MathBlockValue.Vector([-1d, 2d, -3d]), 2d, DimensionlessPathScalar);
    }
}
