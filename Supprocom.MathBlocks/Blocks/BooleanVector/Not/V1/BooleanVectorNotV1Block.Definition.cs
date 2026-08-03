namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class BooleanVectorNotV1Block
    {
        internal const string Identity = "boolean-vector.not@1";
        internal static MathBlockOperation Create() => BooleanVectorNotV1BlockCpu.Create();
    }
}
