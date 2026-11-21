namespace Supprocom.MathBlocks;

internal static partial class PathMathBlocks
{
    internal static class PathMaximumRelativeDeclineV1Block
    {
        internal const string Identity = "path.maximum-relative-decline@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreatePathScalar("path.maximum-relative-decline", MathBlockPath.MaximumRelativeDecline, MathBlockValue.Vector([1f, 2f, 1f]), 0.5f, DimensionlessPathScalar);
    }
}
