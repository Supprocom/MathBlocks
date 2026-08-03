namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class BooleanVectorOrV1Block
    {
        internal const string Identity = "boolean-vector.or@1";
        internal static MathBlockOperation Create() => BooleanVectorOrV1BlockCpu.Create();
    }
}
