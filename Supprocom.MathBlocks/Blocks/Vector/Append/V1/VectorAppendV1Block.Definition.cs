namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class VectorAppendV1Block
    {
        internal const string Identity = "vector.append@1";
        internal static MathBlockOperation Create() => VectorAppendV1BlockCpu.Create();
    }
}
