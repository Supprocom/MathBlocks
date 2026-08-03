namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class PathTotalVariationV1Block
    {
        internal const string Identity = "path.total-variation@1";
        internal static MathBlockOperation Create() => CreatePathScalar("path.total-variation", MathBlockPath.TotalVariation, path, 6d, SameUnitScalar);
    }
}
