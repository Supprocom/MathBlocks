namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorIndexV1Block
    {
        internal const string Identity = "vector.index@1";
        internal static MathBlockOperation Create() => VectorIndexV1BlockCpu.Create();
    }
}
