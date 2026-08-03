namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorLessThanV1Block
    {
        internal const string Identity = "vector.less-than@1";
        internal static MathBlockOperation Create() => CreateVectorComparison("vector.less-than", MathBlockVectorMath.LessThan, [true, true, false, false ]);
    }
}
