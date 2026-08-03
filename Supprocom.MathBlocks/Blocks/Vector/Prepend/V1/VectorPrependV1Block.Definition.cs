namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class VectorPrependV1Block
    {
        internal const string Identity = "vector.prepend@1";
        internal static MathBlockOperation Create() => VectorPrependV1BlockCpu.Create();
    }
}
