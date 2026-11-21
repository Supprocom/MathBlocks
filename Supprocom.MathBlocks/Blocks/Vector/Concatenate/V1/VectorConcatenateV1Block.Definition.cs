namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class VectorConcatenateV1Block
    {
        internal const string Identity = "vector.concatenate@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Expanding;
        internal static MathBlockOperation Create() => CreateVectorBinary("vector.concatenate", MathBlockVectorMath.Concatenate, [1f, 2f, 3f, 4f, 4f, 3f, 2f, 1f], ConcatenateType, sameLength: false);
    }
}
