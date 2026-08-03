namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class PathMaximumRelativeDeclineV1Block
    {
        internal const string Identity = "path.maximum-relative-decline@1";
        internal static MathBlockOperation Create() => CreatePathScalar("path.maximum-relative-decline", MathBlockPath.MaximumRelativeDecline, MathBlockValue.Vector([1d, 2d, 1d]), 0.5d, DimensionlessPathScalar);
    }
}
