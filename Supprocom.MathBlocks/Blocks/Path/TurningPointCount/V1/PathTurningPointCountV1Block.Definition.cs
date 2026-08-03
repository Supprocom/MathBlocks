namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class PathTurningPointCountV1Block
    {
        internal const string Identity = "path.turning-point-count@1";
        internal static MathBlockOperation Create() => CreatePathScalar("path.turning-point-count", values => MathBlockPath.TurningPointCount(values), path, 2d, DimensionlessPathScalar);
    }
}
