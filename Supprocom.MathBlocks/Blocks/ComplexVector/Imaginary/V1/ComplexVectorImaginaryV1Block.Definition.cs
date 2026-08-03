namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class ComplexVectorImaginaryV1Block
    {
        internal const string Identity = "complex-vector.imaginary@1";
        internal static MathBlockOperation Create() => ComplexVectorImaginaryV1BlockCpu.Create();
    }
}
