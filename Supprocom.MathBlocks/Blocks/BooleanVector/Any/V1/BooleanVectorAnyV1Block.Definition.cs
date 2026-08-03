namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class BooleanVectorAnyV1Block
    {
        internal const string Identity = "boolean-vector.any@1";
        internal static MathBlockOperation Create() => BooleanVectorAnyV1BlockCpu.Create();
    }
}
