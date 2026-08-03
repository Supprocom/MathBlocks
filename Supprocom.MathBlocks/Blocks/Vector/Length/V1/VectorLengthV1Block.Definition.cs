namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorLengthV1Block
    {
        internal const string Identity = "vector.length@1";
        internal static MathBlockOperation Create() => VectorLengthV1BlockCpu.Create();
    }
}
