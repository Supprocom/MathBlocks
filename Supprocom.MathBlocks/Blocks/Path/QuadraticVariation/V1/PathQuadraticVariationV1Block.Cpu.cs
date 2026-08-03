namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class PathQuadraticVariationV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreatePathScalar("path.quadratic-variation", values => MathBlockPath.PowerVariation(values, 2d), path, 14d, QuadraticVariationType);
    }
}
