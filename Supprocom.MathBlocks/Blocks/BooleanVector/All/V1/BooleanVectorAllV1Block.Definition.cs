namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class BooleanVectorAllV1Block
    {
        internal const string Identity = "boolean-vector.all@1";
        internal static MathBlockOperation Create() => BooleanVectorAllV1BlockCpu.Create();
    }
}
