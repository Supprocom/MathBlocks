namespace Supprocom.MathBlocks;

internal static partial class PathMathBlocks
{
    internal static class PathZeroCrossingCountV1Block
    {
        internal const string Identity = "path.zero-crossing-count@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreatePathScalar("path.zero-crossing-count", values => MathBlockPath.ZeroCrossingCount(values), MathBlockValue.Vector([-1f, 2f, -3f]), 2f, DimensionlessPathScalar);
    }
}
