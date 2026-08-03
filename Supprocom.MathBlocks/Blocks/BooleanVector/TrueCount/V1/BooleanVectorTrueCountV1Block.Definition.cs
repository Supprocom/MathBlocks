namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class BooleanVectorTrueCountV1Block
    {
        internal const string Identity = "boolean-vector.true-count@1";
        internal static MathBlockOperation Create() => BooleanVectorTrueCountV1BlockCpu.Create();
    }
}
