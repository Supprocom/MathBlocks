namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class PathReflectedCumulativeSumV1Block
    {
        internal const string Identity = "path.reflected-cumulative-sum@1";
        internal static MathBlockOperation Create() => CreatePathVector("path.reflected-cumulative-sum", MathBlockPath.ReflectedCumulativeSum, MathBlockValue.Vector([-2d, 1d, 2d]), [0d, 1d, 3d], SameUnitVector);
    }
}
