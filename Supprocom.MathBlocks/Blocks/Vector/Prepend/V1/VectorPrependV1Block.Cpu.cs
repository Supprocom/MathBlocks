namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class VectorPrependV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateAppend("vector.prepend", prepend: true);
    }
}
