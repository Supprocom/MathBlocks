namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class VectorAppendV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateAppend("vector.append", prepend: false);
    }
}
