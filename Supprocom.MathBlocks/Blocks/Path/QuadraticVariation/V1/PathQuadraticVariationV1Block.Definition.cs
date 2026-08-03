namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class PathQuadraticVariationV1Block
    {
        internal const string Identity = "path.quadratic-variation@1";
        internal static MathBlockOperation Create() => PathQuadraticVariationV1BlockCpu.Create();
    }
}
