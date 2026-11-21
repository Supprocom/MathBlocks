namespace Supprocom.MathBlocks;

internal static partial class PathMathBlocks
{
    internal static class PathReflectedCumulativeSumV1Block
    {
        internal const string Identity = "path.reflected-cumulative-sum@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Expanding;
        internal static MathBlockOperation Create() => CreatePathVector("path.reflected-cumulative-sum", MathBlockPath.ReflectedCumulativeSum, MathBlockValue.Vector([-2f, 1f, 2f]), [0f, 1f, 3f], SameUnitVector);
    }
}
