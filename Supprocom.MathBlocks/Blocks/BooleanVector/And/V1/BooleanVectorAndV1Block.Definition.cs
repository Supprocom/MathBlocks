namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class BooleanVectorAndV1Block
    {
        internal const string Identity = "boolean-vector.and@1";
        internal static MathBlockOperation Create() => BooleanVectorAndV1BlockCpu.Create();
    }
}
