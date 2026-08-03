namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorConcatenateV1Block
    {
        internal const string Identity = "vector.concatenate@1";
        internal static MathBlockOperation Create() => CreateVectorBinary("vector.concatenate", MathBlockVectorMath.Concatenate, [1d, 2d, 3d, 4d, 4d, 3d, 2d, 1d], ConcatenateType);
    }
}
