namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorSortV1Block
    {
        internal const string Identity = "vector.sort@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateVectorUnary("vector.sort", MathBlockVectorMath.Sort, [3f, 1f, 2f], [1f, 2f, 3f], SameVectorUnary);
    }
}
