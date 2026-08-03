namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class ComplexVectorRealV1Block
    {
        internal const string Identity = "complex-vector.real@1";
        internal static MathBlockOperation Create() => ComplexVectorRealV1BlockCpu.Create();
    }
}
