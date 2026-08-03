namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorAddV1Block
    {
        internal const string Identity = "vector.add@1";
        internal static MathBlockOperation Create() => CreateVectorBinary("vector.add", MathBlockVectorMath.Add, [5d, 5d, 5d, 5d], SameVectors);
    }
}
