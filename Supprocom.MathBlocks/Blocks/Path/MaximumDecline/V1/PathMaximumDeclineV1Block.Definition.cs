namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class PathMaximumDeclineV1Block
    {
        internal const string Identity = "path.maximum-decline@1";
        internal static MathBlockOperation Create() => CreatePathScalar("path.maximum-decline", MathBlockPath.MaximumDecline, path, 1d, SameUnitScalar);
    }
}
