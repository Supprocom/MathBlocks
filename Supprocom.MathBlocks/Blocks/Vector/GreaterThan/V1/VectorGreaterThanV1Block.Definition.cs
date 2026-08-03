namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorGreaterThanV1Block
    {
        internal const string Identity = "vector.greater-than@1";
        internal static MathBlockOperation Create() => CreateVectorComparison("vector.greater-than", MathBlockVectorMath.GreaterThan, [false, false, true, true ]);
    }
}
