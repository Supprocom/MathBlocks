namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class BooleanVectorXorV1Block
    {
        internal const string Identity = "boolean-vector.xor@1";
        internal static MathBlockOperation Create() => BooleanVectorXorV1BlockCpu.Create();
    }
}
